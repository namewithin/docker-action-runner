#!/bin/bash

if [[ -z $REPO && -z $ORG ]]; then
  echo "Error : REPO or ORG variable must be set."
  exit 1
fi

if [[ -z $ACCESS_TOKEN ]]; then
  echo "Error : ACCESS_TOKEN variable must be set."
  exit 1
fi

if [[ ! -z $ORG ]]; then
  SCOPE="orgs"
  GH_TARGET="${ORG}"
else
  SCOPE="repos"
  GH_TARGET="${REPO}"
fi
echo "initializing runner..."

AUTHORIZE_HEADER="Authorization: token ${ACCESS_TOKEN}"
echo "AUTHORIZE_HEADER=${AUTHORIZE_HEADER}"

echo "NO BRACKETS"
curl -X POST -H "${AUTHORIZE_HEADER}" "https://api.github.com/${SCOPE}/${GH_TARGET}/actions/runners/registration-token"
echo "WITH BRACKETS"
curl -X POST -H \"${AUTHORIZE_HEADER}\" "https://api.github.com/${SCOPE}/${GH_TARGET}/actions/runners/registration-token"
echo "WITH BRACKETS AND REDIRECT"
curl -X POST -H \"${AUTHORIZE_HEADER}\" "https://api.github.com/${SCOPE}/${GH_TARGET}/actions/runners/registration-token" >> /home/runner/registration-token.json
cat /home/runner/registration-token.json | jq .token --raw-output

REG_TOKEN=$(curl -sX POST -H \"${AUTHORIZE_HEADER}\" "https://api.github.com/${SCOPE}/${GH_TARGET}/actions/runners/registration-token" | jq .token --raw-output)
echo "REG_TOKEN=${REG_TOKEN}"

CONFIG_OPTIONS="--token ${REG_TOKEN}"

if [[ -n $RUNNER_LABELS ]]; then
  CONFIG_OPTIONS="${CONFIG_OPTIONS} --labels ${RUNNER_LABELS}"
fi

if [[ -n $RUNNER_GROUP ]]; then
  CONFIG_OPTIONS="${CONFIG_OPTIONS} --runnergroup ${RUNNER_GROUP}"
fi

if [ "$(echo $RUNNER_REPLACE_EXISTING | tr '[:upper:]' '[:lower:]')" == "true" ]; then
	CONFIG_OPTIONS="${CONFIG_OPTIONS} --replace"
fi

# shellcheck disable=SC2164
cd /home/runner
echo "registering runner...";
if [ "$(echo $RUNNER_DEBUG | tr '[:upper:]' '[:lower:]')" == "true" ]; then
	echo "ORG=${ORG}"
  echo "GH_TARGET=${GH_TARGET}"
  echo "SCOPE=${SCOPE}"
  echo "RUNNER_ALLOW_RUNASROOT=${RUNNER_ALLOW_RUNASROOT}"
  echo "RUNNER_DEBUG=${RUNNER_DEBUG}"
  echo "RUNNER_LABELS=${RUNNER_LABELS}"
  echo "RUNNER_GROUP=${RUNNER_GROUP}"
  echo "RUNNER_REPLACE_EXISTING=${RUNNER_REPLACE_EXISTING}"
  echo "ACCESS_TOKEN=${ACCESS_TOKEN}"
  echo "CONFIG_OPTIONS=${CONFIG_OPTIONS}"
  echo REG_TOKEN=curl -sX POST -H "Authorization: token ${ACCESS_TOKEN}" https://api.github.com/${SCOPE}/${GH_TARGET}/actions/runners/registration-token
fi
RUNNER_ALLOW_RUNASROOT="1" ./config.sh --unattended --url https://github.com/${GH_TARGET} ${CONFIG_OPTIONS} --work /home/runner/work ;

if [ "$(echo $RUNNER_DEBUG | tr '[:upper:]' '[:lower:]')" == "true" ]; then
  curl -sX POST -H "${AUTHORIZE_HEADER}" https://api.github.com/${SCOPE}/${GH_TARGET}/actions/runners/registration-token
fi

cleanup() {
  echo "removing runner..."
  REG_TOKEN=$(curl -sX POST -H "Authorization: token ${ACCESS_TOKEN}" https://api.github.com/${SCOPE}/${GH_TARGET}/actions/runners/registration-token | jq .token --raw-output)
  RUNNER_ALLOW_RUNASROOT="1" ./config.sh remove --unattended --token ${REG_TOKEN}
  exit
}

trap cleanup SIGINT SIGQUIT SIGTERM TERM INT QUIT

echo "running service"
#./bin/Runner.Listener run --startuptype service
./bin/runsvc.sh
