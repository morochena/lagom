FROM nginx:alpine

RUN apk update && apk upgrade
RUN apk add alpine-sdk libffi-dev zlib-dev

RUN apk add --no-cache \
  ruby \
  ruby-bundler \
  ruby-bigdecimal \
  ruby-json \
  ruby-dev \
  build-base

RUN mkdir /app
WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN bundle install
RUN bundle exec jekyll build

ADD . /app

RUN mkdir /usr/share/nginx/html
RUN cp -r /app/_site/. /usr/share/nginx/html/.

EXPOSE 80
