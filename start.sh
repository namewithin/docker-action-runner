#!/bin/bash

if [[ -z $REPO && -z $ORG ]]; then
  echo "Error : REPO or ORG variable must be set."
  exit 1
fi

if [[ ! -z $ORG ]]; then
  SCOPE="orgs"
  GH_TARGET="${ORG}"
else
  SCOPE="repos"
  GH_TARGET="${REPO}"
fi

REG_TOKEN=$(curl -sX POST -H "Authorization: token ${ACCESS_TOKEN}" https://api.github.com/${SCOPE}/${GH_TARGET}/actions/runners/registration-token | jq .token --raw-output)
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
RUNNER_ALLOW_RUNASROOT="1" ./config.sh --unattended --url https://github.com/${GH_TARGET} ${CONFIG_OPTIONS} --work /home/runner/work ;

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