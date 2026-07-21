FROM ruby:3.4
LABEL maintainer "@tdtds <t@tdtds.jp>"

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY [ "Gemfile", "Gemfile.lock", "/usr/src/app/" ]
ENV BUNDLE_WITH=docker \
    BUNDLE_WITHOUT=development:test \
    BUNDLE_PATH=vendor/bundle
RUN apt update && apt install -y apt-utils libidn11-dev; \
    gem install bundler && \
    bundle install --jobs=4 --retry=3

COPY . /usr/src/app/
RUN if [ ! -e tdiary.conf ]; then cp tdiary.conf.beginner tdiary.conf; fi && \
    bundle install && \
    bundle exec rake assets:copy

VOLUME [ "/usr/src/app/data", "/usr/src/app/public" ]
EXPOSE 9292
ENV PORT=9292
ENV HTPASSWD=data/.htpasswd
ENV RACK_ENV=deployment
CMD bundle exec rackup -o 0.0.0.0 -p ${PORT}
