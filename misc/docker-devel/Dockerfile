FROM ruby:2.5
MAINTAINER Tada, Tadashi @tdtds

RUN mkdir -p /usr/src/app
WORKDIR /usr/src
COPY [ "run-app.sh", "/usr/src/" ]
EXPOSE 9292
CMD "/usr/src/run-app.sh"
