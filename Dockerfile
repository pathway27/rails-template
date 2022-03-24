# TODO: MIGRATIONS

FROM ruby:3.1.1-alpine

RUN apk --update add build-base nodejs tzdata postgresql-dev postgresql-client libxslt-dev libxml2-dev imagemagick

ENV INSTALL_PATH /usr/src/app

WORKDIR $INSTALL_PATH

COPY Gemfile* .ruby-version ./

ARG RAILS_ENV
ENV RACK_ENV=$RAILS_ENV

RUN gem install bundler

# Finish establishing our Ruby enviornment depending on the RAILS_ENV
RUN if [[ "$RAILS_ENV" == "production" ]]; then bundle install --without development test; else bundle install; fi

# Copy the main application.
#RUN bundle config set --local deployment 'true'
#RUN bundle config set --local without 'test development'
#RUN bundle install --jobs 5

COPY . ./
