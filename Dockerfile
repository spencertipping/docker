FROM ubuntu:16.04

# Prevent the keyboard-configuration package setup from blocking the apt-get
# install below
ADD etc-keyboard /etc/default/keyboard

RUN sed -i 's/^#\s*\(deb.*multiverse\)$/\1/g' /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y apt-transport-https

RUN echo deb https://packagecloud.io/github/git-lfs/ubuntu/ xenial main \
      >> /etc/apt/sources.list \
 && echo deb-src https://packagecloud.io/github/git-lfs/ubuntu/ xenial main \
      >> /etc/apt/sources.list

# Unauthenticated is OK here because we're on HTTPS
RUN apt-get update \
 && apt-get install -y --allow-unauthenticated git-lfs

RUN apt-get install -y \
      tmux xpra htop atop git openssh-server sudo man \
      octave ruby python3 perl jq gnuplot5 pdl libdevel-repl-perl \
      pv units curl \
      lzop pbzip2 zip unzip liblz4-tool zpaq lrzip \
      python-pip python-scipy python3-pip python3-scipy \
      ffmpeg octave-image octave-parallel \
      chromium-browser darktable audacity

RUN pip install tensorflow

RUN echo user_allow_other >> /etc/fuse.conf

ENV user=spencertipping
RUN useradd -ms /bin/bash $user -G adm,sudo \
 && echo "    IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config \
 && echo "%sudo ALL=NOPASSWD: ALL" >> /etc/sudoers \
 && mkdir /var/run/sshd

ADD authorized_keys user-setup repositories git-versions /home/$user/
RUN chown $user:$user /home/$user/authorized_keys \
 && chmod 0700 /home/$user/authorized_keys

USER $user
WORKDIR /home/$user
RUN ./user-setup

EXPOSE 22
VOLUME /mnt

USER root
WORKDIR /
CMD ["/usr/sbin/sshd", "-D"]
