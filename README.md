# General

This is an inofficial project and has nothing to do with Internxt!

Aim of this project is to provide the official @internxt/cli from https://www.npmjs.com/package/@internxt/cli usable in a docker image (e.g. for webdav).

This is provided free and as stated in the license feel free to use at your own risk.

- Github: https://github.com/ruepp-jenkins/docker-internxt-cli
- Docker: https://hub.docker.com/repository/docker/ruepp/internxt-cli

# Features

## basic features

This container installs the official cli using the npm package. So all features from the package are available and should work.

## additional scripts

In addition there are some helpful scripts in `/scripts` folder you can use. They are described below and give you the following options:

- start the webdav server
- start the webdav server and automatically loggin if credentials expire
- login script (not meant to be run by hand, using docker features is also easier, see example sections the `docker run` commands)

# Security

Using this image you can provide your credentials for an automatically login procedure to ensure that the webdav server is not inaccessable if the credential token has expired. To do so you can provide your credentials using the environment variables.

Using this container leads into storing access information to be able to use them inside the container by the cli.

**<span style="color: red;">ATTENTION:</span>**

Those should always be kept a secret as anyone can use them to access Internxt as yourself.

## Token

The cli needs a valid token to operate with. This token is created by the cli and stored in your `/config` directory. It usually is a long password like text which provides something like API access to your Internxt account.

## Credentials

If you want to use the automatically login feature you need to provide the username, password and the one time password secret (if used). Using those credentials anyone can login to your account without any restrictions.

As those information needs to be provided by docker environment variables everyone with access to the docker host, the container or the docker compose files (if used) can extract and use them.

# Paths

| Path | Description |
| ---- | ----------- |
| /config | contains the internxt-cli configuration and authentication information |

The `/config` is just a redirection to  `/home/root/.internxt-cli`

If you want to interact with your local file system you should provide your own mounts as `/config` is managed by the internxt cli itselfe.

# Environment variables (with default values)

| Name | Default | Description |
| ---- | ------- | ----------- |
| TZ | Europe/Berlin | Timezone to use for the container |
| INTERNXT_PASSWORD | | Password for the internxt-cli configuration (only needed for auto login) |
| INTERNXT_USERNAME  | | Username for the internxt-cli configuration (only needed for auto login) |
| INTERNXT_SECRET | | OTP Secret for the internxt-cli configuration (only needed for auto login) |
| WEBDAV_CHECK_INTERVAL | 60 | Interval for checking if webdav server is available or not (in seconds) |
| WEBDAV_CHECK_TIMEOUT | 30 | Timeout for checking if webdav server is available or not (in seconds) |

# Time / Date

If you do not change your timezone (see environment variables) the container will use Europe/Berlin as default timezone. But if you want to make sure it is using the correct time and date, you need to specify your timezone.
List of possible timezones: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones

Examples:

- Europe/Berlin
- Africa/Windhoek
- America/Costa_Rica

# Ports

| Port | Description |
| ---- | ----------- |
| 3005 | Default port of webdav integration, make sure to use it proper like `127.0.0.1:3005:3005` to not provide external access |

# Scripts

## /scripts/webdav.sh

Spawns the webdav server. It uses the configuration and credentials inside the `/config` folder. It checks every 10 seconds if the server gives a correct response. If not the docker container dies.

## /scripts/webdav_with_login.sh

Same like `/scripts/webdav.sh` but in addition performs a login using `/scripts/login.sh` if needed. For details how to configure the login see the `/scripts/login.sh` below.

## /scripts/login.sh

Logs you into your Internxt account using the environment variables `INTERNXT_USERNAME`, `INTERNXT_PASSWORD` and `INTERNXT_SECRET`. I uses `internxt whoami` to check if login is really needed. Not meant to be run by hand.

# Examples

## Docker Compose: without credentials

This starts the webdav server with the credentials from the config file. It dies as soon as the webdav server is no longer able to correctly answer to the webdav requests made by the script.

```yaml
services:
  internxt-cli-webdav:
    container_name: internxt-cli-webdav
    restart: unless-stopped
    image: ruepp/internxt-cli
    command: [ "/scripts/webdav.sh" ]
    # as internxt can consume a lot of cpu resources your can also run it in nice mode from lowest priority 19 over normal 0 to highest -20 (not recommended)
    # command: [ "nice", "-n", "10", "/scripts/webdav.sh" ] # run in lower priority mode 10
    volumes:
      - ./config:/config
    environment:
      TZ: Europe/Berlin
    # the webdav server does not have any credentials, so make sure to
    # only provide access to yourselfe (usually 127.0.0.1) and avoid
    # exposing it to everyone or even worse the internet.
    ports:
      - 127.0.0.1:3005:3005
```

## Docker Compose : with credentials

ATTENTION:
exposing your credentials here gives everyone with access to your docker host or the container itselfe the possibility to log into your Internxt account.

```yaml
services:
  internxt-cli-webdav:
    container_name: internxt-cli-webdav
    restart: unless-stopped
    image: ruepp/internxt-cli
    command: [ "/scripts/webdav_with_login.sh" ]
    # as internxt can consume a lot of cpu resources your can also run it in nice mode from lowest priority 19 over normal 0 to highest -20 (not recommended)
    # command: [ "nice", "-n", "10", "/scripts/webdav_with_login.sh" ] # run in lower priority mode 10
    volumes:
      - ./config:/config
    environment:
      TZ: Europe/Berlin
      # ATTENTION: Read Security part of this readme!
      INTERNXT_USERNAME: <your@email.tld>
      INTERNXT_PASSWORD: <PASSWORD>
      INTERNXT_SECRET: <YourTotpSecret>
    # the webdav server does not have any credentials, so make sure to
    # only provide access to yourselfe (usually 127.0.0.1) and avoid
    # exposing it to everyone or even worse the internet.
    ports:
      - 127.0.0.1:3005:3005
```

## Login or configure internxt by hand

```
# general help
docker run --rm -it -v /path/to/config:/config ruepp/internxt-cli internxt

# login
docker run --rm -it -v /path/to/config:/config ruepp/internxt-cli internxt login

# who am i
docker run --rm -it -v /path/to/config:/config ruepp/internxt-cli internxt whoami

# webdav config (with example)
docker run --rm -it -v /path/to/config:/config ruepp/internxt-cli internxt webdav-config -s -p 3005 -t 0
```

# Docker Builds
## Tags

Several different tags are built to give you the possibility to use any specific version. But be careful, I do not have a docker subscription, so versions could disappear. As I only build the newest versions they are then lost and are not coming back.

## Automatic builds

All builds are done automatically using a self hosted Jenkins environment. The build steps and configuration is defined in the `Jenkinsfile` and can be read from Jenkins to create a pipeline project from it.

As the steps differ between arm64 and amd64 architecture all needed steps to build the image are in the `scripts` folder.

## Requirements

- Jenkins
- Jenkins agent with installed docker
- Plugin UrlTrigger

## Variables

The build script logs into docker bevore building the image. For this you need to set in you agent these variables:

- DOCKER_USERNAME
- DOCKER_PASSWORD (docker api password)

## Agent

You need at least one agent with the label `docker` which has an installed and working docker environment.

# License

MIT License

Copyright (c) 2025 Stefan Ruepp https://github.com/ruepp-jenkins/docker-internxt-cli

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
