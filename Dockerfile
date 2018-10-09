FROM ubuntu:18.04

# Prevent the keyboard-configuration package setup from blocking the apt-get
# install below
ADD etc-keyboard /etc/default/keyboard

ENV DEBIAN_FRONTEND noninteractive

RUN sed -i 's/^#\s*\(deb.*multiverse\)$/\1/g' /etc/apt/sources.list \
 && apt-get update

# Install SSH server, but delete the keys and instead use a volume mounted later
# on. This way I'm not pushing server keys into dockerhub.
VOLUME /ssh-host-keys
RUN apt-get install -y openssh-server \
 && rm -f /etc/ssh/ssh_host_*_key \
 && ln -s /ssh-host-keys/ssh_host_rsa_key /etc/ssh/ \
 && ln -s /ssh-host-keys/ssh_host_dsa_key /etc/ssh/ \
 && ln -s /ssh-host-keys/ssh_host_ed25519_key /etc/ssh/

RUN apt-get install -y \
      tmux xpra htop atop git sudo man vim \
      octave ruby python3 perl jq gnuplot5 pdl libdevel-repl-perl \
      pv units curl \
      lzop pbzip2 zip unzip liblz4-tool zpaq lrzip p7zip-full \
      python-pip python-scipy python3-pip python3-scipy \
      ffmpeg octave-image octave-parallel \
      chromium-browser darktable audacity git-lfs

RUN pip install tensorflow
RUN pip install platformio

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
RUN bash user-setup

EXPOSE 22
VOLUME /mnt

ADD generate-host-keys fix-dev-shm /usr/sbin/

USER root
WORKDIR /
CMD /usr/sbin/generate-host-keys \
 && /usr/sbin/fix-dev-shm \
 && /usr/sbin/sshd -D
