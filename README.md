# docker_ooye

A docker container for the Out Of Your Element ( OOYE ) Matrix-to-Discord bridge. OOYE makes it
_super_ easy to bridge your Discord server to matrix, and this container makes it easy to deploy.

> **Under Construction 🚧:** The instructions are under construction.

## Usage

### Create Discord Bot

The first step is to create a Discord bot that can be invited to the discord servers that you want
to bridge to matrix.

1. Go to the [Discord Developer Applications page](https://discord.com/developers/applications).
2. Click "New Application".
3. Give it a name like "My Bridge Bot" and click "Create".
4. Go to the "Bot" tab in the left sidebar.
5. Scroll down and click the "Reset Token" button.
6. Confirm with "Yes, do it!" button.
7. There will now be a token displayed.
8. Click "Copy" below the token, and save that for future reference.

### Setup OOYE

Now we can run our OOYE bridge.

1. Run the following command on your server **twice**, to generate two random 64 character hex keys,
  and save the keys for future reference.
  ```
  dd if=/dev/urandom bs=32 count=1 2> /dev/null | basenc --base16 | dd conv=lcase 2> /dev/null
  ```
2. Create a `docker-compose.yml` like the one below, but with your server info and tokens substituted
  in the `environment` section.
  ```yaml
services:
  ooye:
    image: ghcr.io/katharostech/ooye:master
    environment:
      SERVER_NAME: your.server.name
      SERVER_ORIGIN: https://your.server.name
      ADMIN_INVITE: "@your_admin_user:some.matrix.server.that.could.be.your.server.name.or.not"
      URL: http://address_of_ooye_from_your.server.name:6693
      HS_TOKEN: your_first_random_token
      AS_TOKEN: your_second_random_token
      DISCORD_TOKEN: your_discord_bot_token
    ports:
      - 6693:6693
    volumes:
      - ooye-data:/app/db

volumes:
  ooye-data:
  ```
