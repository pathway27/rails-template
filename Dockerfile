FROM ruby:3.1.1-alpine AS base

RUN apk add --update postgresql-client \
		     tzdata \
		     libxml2 \
		     libxslt \
		     yarn
FROM base as dependencies

RUN apk add --no-cache postgresql-dev build-base libxml2-dev libxslt-dev
COPY Gemfile* .ruby-version ./

ARG RAILS_ENV
ENV RACK_ENV=$RAILS_ENV

RUN ruby -v
RUN gem install bundler && \
	bundle config build.nokogiri --use-system-libraries && \
	bundle config set force_ruby_platform true && \
	gem install nokogiri --platform=ruby -- --use-system-libraries && \
	bundle config set without "development test" && \
  	bundle install # --jobs=3 --retry=3

FROM base

RUN adduser -D app
USER app

#ENV INSTALL_PATH /usr/src/app
WORKDIR /home/app

COPY --from=dependencies /usr/local/bundle/ /usr/local/bundle/

# Finally, copy over the code
# This is where the .dockerignore file comes into play
# Note that we have to use `--chown` here
COPY --chown=app . ./

# Finish establishing our Ruby enviornment depending on the RAILS_ENV
#RUN if [[ "$RAILS_ENV" == "production" ]]; then bundle install --without development test; else bundle install; fi
