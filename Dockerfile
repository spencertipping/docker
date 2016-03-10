FROM ubuntu:15.10
ENV user=spencertipping

RUN sed -i 's/^#\s*\(deb.*multiverse\)$/\1/g' /etc/apt/sources.list \
    && apt-get update

# Prevent the keyboard-configuration package setup from blocking the apt-get
# install below
ADD etc-keyboard /etc/default/keyboard

# This is a separate command so the above image can be cached. Not the most
# elegant solution, but otherwise it takes a long time to test.
RUN apt-get install -y tmux xpra htop atop git openssh-server \
                       gnuplot octave ruby python3 perl pdl jq r-base \
                       randomize-lines \
                       sshfs archivemount encfs \
                       pv reptyr rlwrap units \
                       ffmpeg audacity gimp \
                       vim emacs conky chromium-browser \
                       build-essential

RUN apt-get install -y lzop sudo

RUN useradd -ms /bin/bash $user -G adm,sudo \
    && echo "    IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config \
    && echo "%sudo ALL=NOPASSWD: ALL" >> /etc/sudoers \
    && mkdir /var/run/sshd

ADD id_rsa.pub user-setup /home/$user/
RUN chown $user:$user /home/$user/id_rsa.pub \
    && chmod 0700 /home/$user/id_rsa.pub

USER $user
WORKDIR /home/$user
RUN ./user-setup

EXPOSE 22
VOLUME /mnt

USER root
WORKDIR /
CMD ["/usr/sbin/sshd", "-D"]
