# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.154.2/containers/ruby/.devcontainer/base.Dockerfile

# [Choice] Ruby version: 2, 2.7, 2.6, 2.5
ARG VARIANT="2"
FROM mcr.microsoft.com/vscode/devcontainers/ruby:0-${VARIANT}
LABEL maintainer "@tdtds <t@tdtds.jp>"

# [Option] Install Node.js
ARG INSTALL_NODE="true"
ARG NODE_VERSION="lts/*"
RUN if [ "${INSTALL_NODE}" = "true" ]; then su vscode -c "umask 0002 && . /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} 2>&1"; fi

# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends apt-utils libidn11-dev sqlite3 libsqlite3-dev

# [Optional] Uncomment this line to install additional gems.
ARG CORE="/workspaces/core"
ENV HTPASSWD="${CORE}/.devcontainer/.htpasswd"

# [Optional] Uncomment this line to install global node packages.
EXPOSE 9292
CMD "${CORE}/.devcontainer/run-app.sh"