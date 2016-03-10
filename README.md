# Dockerized remote setup
This lets me install my settings and preferred user tools on a new machine by
launching a docker image, rather than configuring stuff by hand. I use most
machines remotely, so this image just runs an SSH server and headless xpra.

Usage:

```sh
$ cp ~/.ssh/id_rsa.pub .        # this key will be authorized to ssh in
$ vim Dockerfile                # change ENV user= to your username
$ sudo docker build -t me .
$ sudo docker run -p 2222:22 -v /mnt:/some/path -d me
```

You should then be able to SSH into the server and be dropped into a persistent
tmux. Any X applications you run should also persist in an xpra server running
on display 100.
