FROM ruby:2
LABEL maintainer "@tdtds <t@tdtds.jp>"

RUN apt update && apt install -y apt-utils libidn11-dev sqlite3 libsqlite3-dev
RUN mkdir -p /workspace
WORKDIR /workspace
EXPOSE 9292
CMD "/workspace/.devcontainer/run-app.sh"
