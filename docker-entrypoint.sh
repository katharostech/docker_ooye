#!/bin/sh

set -e

# Make sure the database exists
touch /data/ooye.db

cat << EOF > config.js
module.exports = {
	discordToken: "${DISCORD_TOKEN}"
}
EOF

admin_invite_line=""
admin_invite_empty=""

if [ -n "${ADMIN_INVITE}" ]; then
  admin_invite_line="- '${ADMIN_INVITE}'"
else
  admin_invite_empty="[]"
fi

cat << EOF > registration.yaml
id: de8c56117637cb5d9f4ac216f612dc2adb1de4c09ae8d13553f28c33a28147c7
hs_token: ${HS_TOKEN}
as_token: ${AS_TOKEN}
url: ${URL}
sender_localpart: ${NAMESPACE_PREFIX}_bridge_bot
protocols:
  - discord
namespaces:
  users:
    - exclusive: true
      regex: '@${NAMESPACE_PREFIX}.*'
  aliases:
    - exclusive: true
      regex: '#${NAMESPACE_PREFIX}.*'
rate_limited: false
ooye:
  namespace_prefix: ${NAMESPACE_PREFIX}
  max_file_size: 5000000
  server_name: ${SERVER_NAME}
  server_origin: ${SERVER_ORIGIN}
  content_length_workaround: ${CONTENT_LENGTH_WORKAROUND}
  invite: ${admin_invite_empty}
    ${admin_invite_line}
EOF

echo "Here is your registration YAML:"
echo ""
cat registration.yaml
echo ""

echo "Setting up / seeding database if necessary"

emoji_arg=""
if [ -n "${EMOJI_GUILD}" ]; then
  emoji_arg="--emoji-guild=${EMOJI_GUILD}"
fi

node scripts/seed.js $emoji_arg

echo "Starting server"
exec node start.js
