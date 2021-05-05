cp .env.example .env && nano $_

run with scale:

>docker-compose up --scale runner=3 -d

> sudo docker run -d --name=runner --restart unless-stopped \
-e REPO=<organization/repository> \
-e ACCESS_TOKEN=<Org/Repo access token> \
-e RUNNER_LABELS=<LABEL> \
docker-action-runner_runner:latest
