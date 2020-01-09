FROM ruby:2.7
MAINTAINER MATSUOKA Kohei @machu

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY [ "Gemfile", "Gemfile.lock", "/usr/src/app/" ]
RUN apt update && apt install -y apt-utils libidn11-dev; \
    echo 'gem "puma" \n\
    gem "tdiary-contrib" \n\
    gem "tdiary-style-gfm" \n\
    gem "tdiary-style-rd" \n'\
    > Gemfile.local; \
    gem install bundler && \
    bundle --path=vendor/bundle --without=development:test --jobs=4 --retry=3

COPY . /usr/src/app/
RUN if [ ! -e tdiary.conf ]; then cp tdiary.conf.beginner tdiary.conf; fi && \
    bundle && \
    bundle exec rake assets:copy

VOLUME [ "/usr/src/app/data", "/usr/src/app/public" ]
EXPOSE 9292
ENV PORT=9292
ENV HTPASSWD=data/.htpasswd
CMD bundle exec rackup -o 0.0.0.0 -p ${PORT}
