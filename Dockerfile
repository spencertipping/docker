FROM ubuntu:18.04

VOLUME /ssh-host-keys

# Prevent the keyboard-configuration package setup from blocking the apt-get
# install below
ADD etc-keyboard /etc/default/keyboard

ENV DEBIAN_FRONTEND noninteractive

RUN sed -i 's/^#\s*\(deb.*multiverse\)$/\1/g' /etc/apt/sources.list \
 && apt-get update \
 && apt-get install -y \
      vim-gtk apt-transport-https git git-lfs \
      nmap openvpn sshuttle pv socat \
      sshfs encfs archivemount nfs-client squashfs-tools \
      xzip zip unzip lzop liblz4-tool pbzip2 zpaq lrzip p7zip-full \
      chromium-browser \
      xsel \
      ffmpeg imagemagick feh blender gimp darktable \
      audacity vorbisgain \
      tmux xpra htop atop curl \
      ruby python python3 perl jq ocaml perl-doc ascii dict \
      libdevel-repl-perl pdl \
      curl python3-scipy python-pip python3-pip octave gnuplot \
      docker.io

RUN pip3 install tensorflow \
 && pip  install platformio \
 && echo user_allow_other >> /etc/fuse.conf

# Install SSH server, but delete the keys and instead use a volume mounted later
# on. This way I'm not pushing server keys into dockerhub.
RUN apt-get install -y openssh-server \
 && rm -f /etc/ssh/ssh_host_*_key \
 && ln -s /ssh-host-keys/ssh_host_rsa_key /etc/ssh/ \
 && ln -s /ssh-host-keys/ssh_host_dsa_key /etc/ssh/ \
 && ln -s /ssh-host-keys/ssh_host_ed25519_key /etc/ssh/

# NB: ARG user is here because nothing above depends on it (so we want to reuse
# those layers)
ARG user=spencertipping
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
