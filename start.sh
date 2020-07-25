#!/bin/bash

REPO_URL=$REPO_URL
ACCESS_TOKEN=$ACCESS_TOKEN

REG_TOKEN=$(curl -sX POST -H "Authorization: token ${ACCESS_TOKEN}" https://api.github.com/repos/${REPO_URL}/actions/runners/registration-token | jq .token --raw-output)

# shellcheck disable=SC2164
cd /home/docker/actions-runner

echo "Registering runner..."
./config.sh --url https://github.com/${REPO_URL} --token ${REG_TOKEN}

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!