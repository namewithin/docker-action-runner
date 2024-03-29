FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
ENV SONAR_SCAN_VERSION=4.7.0.2747
RUN apt-get update -y && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    php-xmlwriter php-xml \
    curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev \
    apt-transport-https ca-certificates gnupg-agent software-properties-common php-cli zip unzip iputils-ping supervisor \
    sudo
RUN  add-apt-repository -y ppa:git-core/ppa \
    && apt-get -y update \
    && apt-get install -y git php-xml php-mbstring php-curl
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable" \
    && apt-get update
RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer --2
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable" \
    && apt-get update \
    && apt-get install -y docker-ce-cli=5:20.10.7~3-0~ubuntu-focal docker-ce=5:20.10.7~3-0~ubuntu-focal
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - &&  apt-get install -y nodejs
RUN echo $(docker -v)
RUN curl -O -L https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$SONAR_SCAN_VERSION-linux.zip \
    && unzip sonar-scanner-cli-$SONAR_SCAN_VERSION-linux.zip \
    && rm sonar-scanner-cli-$SONAR_SCAN_VERSION-linux.zip \
    && sudo mv sonar-scanner-$SONAR_SCAN_VERSION-linux /opt/sonarscanner \
    && chmod +x /opt/sonarscanner/bin/sonar-scanner \
    && ln -s /opt/sonarscanner/bin/sonar-scanner /usr/local/bin/sonar-scanner
RUN mkdir -p /home/runner
WORKDIR /home/runner
RUN runner_version="$(curl --silent "https://raw.githubusercontent.com/actions/runner/main/src/runnerversion")" \
    && curl -O -L https://github.com/actions/runner/releases/download/v{$runner_version}/actions-runner-linux-x64-$runner_version.tar.gz \
    && tar xzf ./actions-runner-linux-x64-$runner_version.tar.gz \
    && /home/runner/bin/installdependencies.sh \
    && chown -R root: /home/runner
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean -y
COPY start.sh start.sh
RUN chmod +x start.sh

ENTRYPOINT ["/home/runner/start.sh"]
