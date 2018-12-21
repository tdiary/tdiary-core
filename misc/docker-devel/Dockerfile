FROM ruby:2.5
LABEL maintainer "@tdtds <t@tdtds.jp>"

RUN mkdir -p /usr/src/app
WORKDIR /usr/src
COPY [ "run-app.sh", "/usr/src/" ]
EXPOSE 9292
CMD "/usr/src/run-app.sh"
