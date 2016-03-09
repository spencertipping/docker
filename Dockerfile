FROM ubuntu:15.10
ARG user=spencertipping

RUN apt-get update \
    && apt-get install -y tmux xpra htop git openssh-server \
                          sshfs archivemount encfs \
                          gnuplot octave chromium-browser \
                          libterm-readline-gnu-perl

RUN useradd -ms /bin/bash $user -G adm,sudo

USER $user
WORKDIR /home/$user

ADD id_rsa.pub user-setup ./
RUN ./user-setup

EXPOSE 22
VOLUME /mnt
CMD ["/bin/bash"]
