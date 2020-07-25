#!/bin/bash

REG_TOKEN=$(curl -sX POST -H "Authorization: token ${ACCESS_TOKEN}" https://api.github.com/repos/${REPO}/actions/runners/registration-token | jq .token --raw-output)
CONFIG_OPTIONS="--token ${REG_TOKEN}"
# shellcheck disable=SC2164

if [[ -n $RUNNER_LABELS ]]; then
    CONFIG_OPTIONS="${CONFIG_OPTIONS} --labels ${RUNNER_LABELS}"
fi


cd /home/docker/actions-runner
echo "Registering runner..."
./config.sh --url https://github.com/${REPO} ${CONFIG_OPTIONS}

cleanup() {
  echo "Removing runner..."
  ./config.sh remove --unattended --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh &
wait $!
