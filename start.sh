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

# shellcheck disable=SC2164
cd /home/docker/actions-runner
echo "Registering runner..."
./config.sh --url https://github.com/${REPO} ${CONFIG_OPTIONS}

cleanup() {
  echo "Removing runner..."
  REG_TOKEN=$(curl -sX POST -H "Authorization: token ${ACCESS_TOKEN}" https://api.github.com/${SCOPE}/${GH_TARGET}/actions/runners/registration-token | jq .token --raw-output)
  ./config.sh remove --unattended --token ${REG_TOKEN}
  exit
}

trap cleanup SIGINT SIGQUIT SIGTERM TERM

./bin/runsvc.sh
