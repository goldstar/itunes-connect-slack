FROM ruby:2.5-alpine3.10 as build

ENV BUILD_DIR /build
WORKDIR $BUILD_DIR

RUN apk add --update --no-cache \
        build-base \
        linux-headers

COPY Gemfile* /build/
COPY vendor/cache vendor/cache
RUN bundle config --global frozen 1 && \
    bundle install --without development -j4 --retry 3
COPY . /build
RUN rm -rf /usr/local/bundle/cache/*.gem && \
    rm -f vendor/cache/*.gem && \
    find /usr/local/bundle/gems/ -name "*.c" -delete && \
    find /usr/local/bundle/gems/ -name "*.o" -delete

FROM ruby:2.5-alpine3.10

RUN apk add --update --no-cache dcron
COPY --from=build /build/ /app/
COPY --from=build /usr/local/bundle/ /usr/local/bundle/
ENV CRON_STRINGS="0 * * * * sh /app/poll.sh"
ENTRYPOINT ["/app/entrypoint.sh"]
WORKDIR /app
CMD ["tail", "-f", "/var/log/cron.log"]
