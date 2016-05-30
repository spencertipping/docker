FROM ubuntu:16.04

# Prevent the keyboard-configuration package setup from blocking the apt-get
# install below
ADD etc-keyboard /etc/default/keyboard

RUN sed -i 's/^#\s*\(deb.*multiverse\)$/\1/g' /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y tmux xpra htop atop git openssh-server parallel \
                          sudo squashfs-tools aufs-tools nfs-common \
                          gnuplot gnuplot5-qt octave ruby python3 perl pdl jq \
                          r-base \
                          sshfs archivemount encfs lftp lsof \
                          pv reptyr rlwrap units curl \
                          lzop zip unzip liblz4-tool \
                          python-pip python-scipy python3-pip python3-scipy \
                          python-sklearn vowpal-wabbit \
                          build-essential openvpn vim

RUN apt-get install -y wamerican maven blender \
                       ffmpeg audacity gimp \
                       emacs conky firefox \
                       thrift-compiler python-thrift \
                       protobuf-compiler python-protobuf \
                       octave-image octave-parallel

# This fails to install on 16.04
#RUN pip3 install --upgrade \
#    https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-0.7.1-cp34-none-linux_x86_64.whl

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
