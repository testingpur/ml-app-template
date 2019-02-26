# ================================================================= #
# ------------ First stage in our multistage Dockerfile ----------- #
# ================================================================= #
FROM python:3.6-slim as Base

RUN apt-get update \
  && apt-get install -y curl git

WORKDIR /home/ci-workshop-app

COPY requirements.txt /home/ci-workshop-app/requirements.txt
RUN pip install -r requirements.txt

COPY . /home/ci-workshop-app

# ================================================================= #
# ------------ Second stage in our multistage Dockerfile ---------- #
# ================================================================= #

FROM Base as Build

# WORKDIR /home/ci-workshop-app
# COPY . /home/ci-workshop-app
# RUN ls -la /home/ci-workshop-app/bin

# TODO: figure out why the line below doesn't work on windows
RUN /home/ci-workshop-app/bin/train_model.sh

CMD ["/home/ci-workshop-app/bin/start_server.sh"]

# ================================================================= #
# ------------ Third stage in our multistage Dockerfile ----------- #
# ================================================================= #
FROM Build as Dev

RUN apt-get install -y gnupg \
  && curl https://cli-assets.heroku.com/install-ubuntu.sh | sh

COPY requirements-dev.txt /home/ci-workshop-app/requirements-dev.txt
RUN pip install -r /home/ci-workshop-app/requirements-dev.txt

RUN git config --global credential.helper 'cache --timeout=36000'

ARG user
RUN useradd ${user:-root} -g root || true
USER ${user:-root}

RUN mkdir -p /home/${user}

EXPOSE 8080
CMD ["/home/ci-workshop-app/bin/start_server.sh"]
