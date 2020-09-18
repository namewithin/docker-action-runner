FROM ubuntu:18.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && apt-get upgrade -y \
    && useradd -m docker \
    && apt-get install -y --no-install-recommends \
     curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev git apt-transport-https ca-certificates gnupg-agent software-properties-common php-cli zip unzip
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
 && add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable" \
        && apt-get update
RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
 && curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh \
 && curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose \
 && curl -sL https://deb.nodesource.com/setup_10.x | bash - &&  apt-get install -y nodejs \
 && usermod -aG root docker

RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && runner_version="$(curl --silent "https://raw.githubusercontent.com/actions/runner/main/src/runnerversion")" \
    && curl -O -L https://github.com/actions/runner/releases/download/v{$runner_version}/actions-runner-linux-x64-$runner_version.tar.gz \
    && tar xzf ./actions-runner-linux-x64-$runner_version.tar.gz \
    && chown -R docker:docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean -y
COPY start.sh start.sh
RUN chmod +x start.sh
USER docker
ENTRYPOINT ["./start.sh"]
