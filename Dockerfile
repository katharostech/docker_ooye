FROM node:18-alpine

RUN apk add --no-cache git
RUN git clone --depth 1 --branch v2.0 https://gitdab.com/cadence/out-of-your-element.git /app
WORKDIR /app
RUN npm i

RUN adduser ooye -D
RUN chown -R ooye /app
USER ooye

ENV DISCORD_TOKEN="notarealdiscordtoken"
ENV SERVER_NAME="notmyrealserver.com"
ENV SERVER_ORIGIN="https://matrix.notmyrealserver.com"
ENV ADMIN_INVITE=""
ENV CONTENT_LENGTH_WORKAROUND="false"
ENV NAMESPACE_PREFIX="_ooye_"
ENV SENDER_LOCALPART="_ooye_bot"
ENV URL="http://localhost:6693"
# These may be generated with:
# dd if=/dev/urandom bs=32 count=1 2> /dev/null | basenc --base16 | dd conv=lcase 2> /dev/null
ENV HS_TOKEN="[a unique 64 character hex string]"
ENV AS_TOKEN="[a unique 64 character hex string]"

VOLUME /app/db

COPY --chmod=744 --chown=1000:1000 ./docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

