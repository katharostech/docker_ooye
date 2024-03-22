# docker_ooye

A docker container for the [Out Of Your Element][ooye] ( OOYE ) Matrix-to-Discord bridge. OOYE makes it
_super_ easy to bridge your Discord server to matrix, and this container makes it easy to deploy.

[ooye]: https://gitdab.com/cadence/out-of-your-element

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
9. Scroll down and make sure that the "MESSAGE CONTENT INTENT" toggle is enabled.

### Setup OOYE

Now we can run our OOYE bridge.

1. Run the following command on your server **twice**, to generate two random 64 character hex keys,
  and save the keys for future reference.
  ```
  dd if=/dev/urandom bs=32 count=1 2> /dev/null | basenc --base16 | dd conv=lcase 2> /dev/null
  ```
2. Create a blank database file for ooye:
   ```bash
touch ooye.db
# OOYE runs as user 1001 in the container
sudo chown 1001:1001 ooye.db
```
2. Create a `docker-compose.yml` like the one below, but with your server info and tokens substituted
  in the `environment` section.
  Note the `ADMIN_INVITE` section, in which you should specify the matrix ID of the user that you want
  to have admin access on the matrix spaces and channels that the bot creates and bridges.
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
      - ./ooye.db:/app/db/ooye.db
  ```
3. In the same folder as your `docker-compose.yml` run `docker compose up -d`.
4. You'll see the container download and start up. It will exit immediately after startup, that is
  expected.
5. Run `docker compose logs --no-log-prefix`.
6. You will see the startup logs printed, and at the top you will see `Here is your registration YAML:`.
  Take the YAML section, which is separated from the rest of the logs by a blank line above and below it,
  and use that to register an Application Service with your matrix server. You can see the [Synapse docs][sd]
  or the [Conduit docs][cd] for how to register the app service with your matrix server.
7. Run `docker compose up -d` again.
8. Run `docker compose logs -f` to follow the logs while the container starts up. A successful startup looks
  like this:
  ```
ooye-1  | Here is your registration YAML:
ooye-1  |
ooye-1  | id: de8c56117637cb5d9f4ac216f612dc2adb1de4c09ae8d13553f28c33a28147c7
ooye-1  | hs_token: 55d271cc660bd2c887408d3f218fdd93cf61be37936948ca15ca180757c1b152
ooye-1  | as_token: cff051af6ae69851fb8b928d9c91da20e17cb7bca437d7fd40b0c9ac2166c332
ooye-1  | url: http://localhost:6693
ooye-1  | sender_localpart: _ooye_bot
ooye-1  | protocols:
ooye-1  |   - discord
ooye-1  | namespaces:
ooye-1  |   users:
ooye-1  |     - exclusive: true
ooye-1  |       regex: '@_ooye_.*'
ooye-1  |   aliases:
ooye-1  |     - exclusive: true
ooye-1  |       regex: '#_ooye_.*'
ooye-1  | rate_limited: false
ooye-1  | ooye:
ooye-1  |   namespace_prefix: _ooye_
ooye-1  |   max_file_size: 5000000
ooye-1  |   server_name: my.matrix.server
ooye-1  |   server_origin: https://my.matrix.server
ooye-1  |   content_length_workaround: false
ooye-1  |   invite:
ooye-1  |     - '@my_username:matrix.org'
ooye-1  |
ooye-1  | Setting up / seeding database if necessary
ooye-1  | This could take up to 30 seconds. Please be patient.
ooye-1  | ✅ Configuration looks good...
ooye-1  | ✅ Database is ready...
ooye-1  | [api] register: _ooye_bot
ooye-1  | ✅ Matrix appservice login works...
ooye-1  | ✅ Emojis are ready...
ooye-1  | ✅ Discord profile updated...
ooye-1  | ✅ Matrix profile updated...
ooye-1  | Good to go. I hope you enjoy Out Of Your Element.
ooye-1  | Starting server
ooye-1  | Discord gateway started
ooye-1  | Discord logged in as My Bridge Bot#2400 (1245678910111213141)
ooye-1  | [2024-03-16T00:16:50 Client Ready]
  ```
9. Press `ctrl+C` to exit stop following the logs once it's ready.

[sd]: https://matrix-org.github.io/synapse/latest/application_services.html
[cd]: https://gitlab.com/famedly/conduit/-/blob/next/APPSERVICES.md

### Invite the Bot To Your Server

Now that we've got our bridge running, we can invite the bot to our Discord guild! OOYE is cool
and allows you to easily bridge multiple Discord guilds without having to run multiple bridges,
so you can follow these steps once for each guild you want to bridge.

1. Run `docker compose exec ooye node addbot.js`.
2. Click the link that is printed out by that command.
3. Select the Discord guild that you want to bridge from the dropdown, and click "Continue".
4. It will show the required permissions. Click "Authorize".
5. Visit your Discord guild and go through every channel and post something like _connecting matrix bridge_.
  Posting in a Discord channel will cause the bridge to create a corresponding matrix channel that matrix
  users will be able to join.

### Configuring Your Matrix Rooms

Your `ADMIN_INVITE` user should receive an invite to any bridge discord spaces. This allows you
to, for instance, make the space public, so that other users can join. Otherwise, you can keep
the space private, and invite whomever you wish.

That's the last step, your matrix bridge is finished!

## Troubleshooting

### `MatrixServerError: User ID already taken.`

If you start an OOYE bridge and connected it to your matrix server, and then you start a new OOYE
bridge, and connect that to the _same_ matrix server, you may get errors from OOYE complaining
that a user ID is already taken. This seems to be because OOYE will create users in matrix that correspond
with the Discord users, but they will have their user ID prefixed with a namespace like `_ooye_`.
If you start a new OOYE bridge and connect it to the same server, it will try to create those
corresponding users with the same ID.

You might be able to fix this by setting the `NAMESPACE_PREFIX` environment
variable in the `environment:` section of your `docker-compose.yaml`, for example:

```yaml
# ...
    environment:
      NAMESPACE_PREFIX: _ooye2_
# ...
```

This seems to resolve some errors, but not all of them, so we're still investigating this.

