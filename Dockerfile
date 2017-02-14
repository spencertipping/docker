FROM gentoo-local

ENV packages tmux htop atop dev-vcs/git openssh sudo \
             octave ruby dev-lang/python dev-python/ipython perl jq \
             pv units net-misc/curl \
             lzop zip unzip app-arch/lz4 app-arch/zpaq app-arch/lrzip \
             dev-python/pip scipy \
             vim \
             app-emulation/docker \
             sshfs encfs archivemount \
             ffmpeg chromium

RUN echo 'CONFIG_PROTECT="-*"' >> /etc/portage/make.conf \
 && sed -ri '/^CPU_FLAGS/ {s/"$/ mmxext"/}' /etc/portage/make.conf \
 && sh -c 'emerge --autounmask y \
                  --ask n \
                  --autounmask-write y $packages; \
           emerge $packages'

RUN sh -c 'emerge --autounmask-write xpra x11-misc/xvfb-run; \
           emerge xpra x11-misc/xvfb-run'

ENV user=spencertipping
RUN echo user_allow_other >> /etc/fuse.conf \
 && echo '10.35.0.3 reykjavik' >> /etc/hosts \
 && useradd -ms /bin/bash $user -G adm,docker \
 && echo "    IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config \
 && echo "%adm ALL=NOPASSWD: ALL" >> /etc/sudoers \
 && mkdir /var/run/sshd \
 && /usr/bin/ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -N "" \
 && /usr/bin/ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ""

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
