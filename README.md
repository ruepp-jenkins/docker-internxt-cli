# General

This is an inofficial project and has nothing to do with Interxt!

Aim of this project is to use the release @internxt/cli version from https://www.npmjs.com/package/@internxt/cli and install it inside a node container.

Use at your own risk!

# Project

Github: https://github.com/ruepp-jenkins/docker-internxt-cli

Docker: https://hub.docker.com/repository/docker/ruepp/internxt-cli

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

# Paths

- /config: contains the internxt-cli configuration and authentication information

The `/config` is just a redirection to `/home/root/.internxt-cli` - so if you change the user you need to adjust the config mount as well.

If you want to use the cli to interact with files on your local disc you need to add mounts as needed.

# Environment variables (with default values)

- TZ=Europe/Berlin
  - Set your timezone here (see Time / Date below)

# Time / Date

If you do not change your timezone (see environment variables) the container will use Europe/Berlin as default timezone. But if you want to make sure it is using the correct time and date, you need to specify your timezone.
List of possible timezones: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones

Examples:

- Europe/Berlin
- Africa/Windhoek
- America/Costa_Rica

# Ports

This image opens the default webdav port 3005

# Examples

## Docker Compose WebDav Server

```yaml
services:
  internxt-cli-webdav:
    container_name: internxt-cli-webdav
    restart: unless-stopped
    image: ruepp/internxt-cli
    command: ["/usr/local/bin/internxt", "webdav", "enable" ]
    volumes:
      - ./config:/config
    environment:
      TZ: Europe/Berlin
    ports:
      - 3005:3005
```

## Login or configure internxt

```
docker run --rm -it -v /path/to/config:/config ruepp/internxt-cli
```

# Tags

Several different tags are built to give you the possibility to use any specific version. But be careful, I do not have a docker subscription, so versions could disappear. As I only build the newest versions they are then lost and are not coming back.


# Github

repository of this container: https://github.com/ruepp-jenkins/docker-internxt-cli

# Automatic builds

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
