FROM ubuntu:15.10
ENV user=spencertipping

RUN sed -i 's/^#\s*\(deb.*multiverse\)$/\1/g' /etc/apt/sources.list \
    && apt-get update

# This is a separate command so the above image can be cached. Not the most
# elegant solution, but otherwise it takes a long time to test.
RUN apt-get install -y tmux xpra htop atop git openssh-server \
                       gnuplot octave ruby python3 perl pdl jq r-base \
                       randomize-lines \
                       sshfs archivemount encfs \
                       pv reptyr rlwrap units \
                       ffmpeg audacity gimp \
                       vim emacs conky \
                       build-essential

RUN useradd -ms /bin/bash $user -G adm,sudo

USER $user
WORKDIR /home/$user

ADD id_rsa.pub user-setup ./
RUN ./user-setup

EXPOSE 22
VOLUME /mnt
CMD ["/bin/bash"]
