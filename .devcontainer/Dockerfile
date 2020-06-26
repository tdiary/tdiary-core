FROM ruby:2
LABEL maintainer "@tdtds <t@tdtds.jp>"

ENV USER vscode
RUN apt update && apt install -y apt-utils libidn11-dev sqlite3 libsqlite3-dev && \
    useradd -m -u 1000 $USER && \
    chsh -s /bin/bash $USER && \
    echo 'git config unset core.sshCommand' >> /home/$USER/.bashrc && \
    echo 'git config unset core.editor' >> /home/$USER/.bashrc && \
    echo './.devcontainer/setup-app.sh' >> /home/$USER/.bashrc && \
    mkdir -p /workspace
USER $USER
WORKDIR /workspace
EXPOSE 9292
CMD "/workspace/.devcontainer/run-app.sh"
