FROM ubuntu:18.04
ENV DEBIAN_FRONTEND=noninteractive
ARG RUNNER_VERSION="2.267.1"
RUN apt-get update -y && apt-get upgrade -y \
    && useradd -m docker \
    && apt-get install -y --no-install-recommends \
     curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev git apt-transport-https ca-certificates gnupg-agent software-properties-common php-cli
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable" \
        && apt-get update
RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer
RUN curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
RUN curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose
RUN usermod -aG root docker
RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
RUN chown -R docker:docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh
RUN rm -rf /var/lib/apt/lists/* \
    && apt-get clean -y
COPY start.sh start.sh
RUN chmod +x start.sh
USER docker
ENTRYPOINT ["./start.sh"]
