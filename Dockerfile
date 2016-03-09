FROM ubuntu:15.10

EXPOSE 22

RUN apt-get update
RUN apt-get install -y tmux xpra htop git openssh-server \
                       sshfs archivemount encfs \
                       gnuplot octave chromium-browser \
                       libterm-readline-gnu-perl

RUN useradd -ms /bin/bash spencertipping -G adm,sudo

USER spencertipping
WORKDIR /home/spencertipping

ADD id_rsa.pub ./
ADD user-setup ./

RUN ./user-setup

CMD ["/bin/bash"]
