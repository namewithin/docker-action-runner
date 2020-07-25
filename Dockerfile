FROM ubuntu:18.04
ARG RUNNER_VERSION="2.267.1"
RUN useradd -m docker
RUN apt update -y && apt install -y curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev
RUN mkdir /home/docker/actions-runner && cd /home/docker/actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

COPY start.sh start.sh
RUN chmod +x start.sh

USER docker

ENTRYPOINT ["./start.sh"]
