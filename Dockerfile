FROM ruby:3.2.2-alpine

RUN apk add --update --no-cache tzdata build-base libffi-dev yajl libc-dev \
    linux-headers libxml2-dev libxslt-dev readline-dev make ruby-json less git \
    readline postgresql-dev nodejs imagemagick file bash \
    && cp /usr/share/zoneinfo/America/Santiago /etc/localtime && echo "America/Santiago" > /etc/timezone \
    && rm -rf /var/lib/apt/lists/*

# Point Bundler at /gems. This will cause Bundler to re-use gems that have already been installed on the gems volume
ENV BUNDLE_PATH /gems
ENV BUNDLE_HOME /gems

# Increase how many threads Bundler uses when installing. Optional!
ENV BUNDLE_JOBS 4

# Where Rubygems will look for gems, similar to BUNDLE_ equivalents.
ENV GEM_HOME /gems
ENV GEM_PATH /gems

# Add /gems/bin to the path so any installed gem binaries are runnable from bash.
ENV PATH /gems/bin:$PATH

RUN mkdir -p /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install
COPY . ./

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]

LABEL maintainer="Leonardo Santis <leonardo.santis.a@gmail.com>"