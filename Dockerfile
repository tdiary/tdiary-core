FROM ruby:2.2
MAINTAINER MATSUOKA Kohei @machu

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY . /usr/src/app/
COPY misc/templates/docker/Gemfile.local /usr/src/app/
COPY misc/templates/docker/tdiary.conf /usr/src/app/
RUN bundle --path=vendor/bundle --without=development:test --jobs=4 --retry=3

VOLUME /usr/src/app/data
EXPOSE 9292
CMD [ "bundle", "exec", "puma" ]
