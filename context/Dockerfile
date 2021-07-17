# This starts with a "minimal" Ubuntu per https://ubuntu.com/blog/minimal-ubuntu-released
# Only 29MB in size and optimized for AWS!  Cool. ;)
#
# However, this configuration installs MapTool and all of its dependents so
# that it can be executed locally within the container.  This bloats the size
# of the image up to ~3GB.
FROM ubuntu:18.04
RUN apt update && \
    apt install -y openssh-server curl sudo
# This is because `sshd` requires `/run/sshd` to exist.
# See https://askubuntu.com/a/1110843/531533
RUN mkdir -p -m0755 /var/run/sshd

# The `tzdata` pkg is (eventually) needed for the `ubuntu-desktop` package.
# Note that its installation is interactive, hence piping some answers into it.
# (The answers are based on US/Eastern time zone.  Your mileage may vary.)
RUN apt update && \
    echo -e "\n12\n5" | apt install -y tzdata

# Don't know if 'cdrom' group is needed, but Ubuntu typically adds it by
# default, so I figured I might as well.  And using Bash is just to make the
# shell more comfortable when I need to login interactively.
RUN groupadd maptool && \
    useradd -m maptool -g maptool -G adm,cdrom && \
    chsh -s /bin/bash maptool

# Need to install a full GUI if we want to run MapTool inside the container.
RUN apt update && \
    apt install -y ubuntu-desktop xdg-utils

# Creates directory as needed, then chdir's to it.
WORKDIR /home/maptool/.ssh

# Download and install a release of MapTool.
# This needs to be parameterized at the time the image is built in the future,
# but I'm not there yet.
#
# This retrieves a JSON object describing the latest release, then looks for
# the asset that ends with '.deb"' (which will be the Debian install package).
# Using both `grep` and `cut` is overkill since `awk` can do both, but this is
# copy/pasted from StackOverflow and I'm being lazy. :)
#RUN curl -L $(curl -s https://api.github.com/repos/RPTools/maptool/releases/latest | grep 'browser_.*[.]deb"' | cut -d\" -f4)

# This grabs a particular release.
RUN curl -LO https://github.com/RPTools/maptool/releases/download/1.9.2/maptool_1.9.2-amd64.deb

# Regardless of which version is downloaded, we should install it and remove
# the package file.  We _could_ leave the file in place, but it just makes the
# image larger, so...
RUN dpkg -i maptool_*.deb && \
    rm maptool_*.deb

# Copy the `.desktop` file to the right place.
RUN mkdir -p /home/maptool/.local/share/applications && \
    cp /opt/maptool/lib/*.desktop /home/maptool/.local/share/applications

# Copies everything in the context directory to the image.
# I'm still playing with the SSHD config, and the `maptool.sudo` is just a
# single line that allows `maptool` to run sudo without needing a password.
COPY . .
RUN chown -R maptool:maptool /home/maptool && \
    chmod 700 . && \
    cat sshd_config.inc >> /etc/ssh/sshd_config && \
    cp maptool.sudo /etc/sudoers.d/maptool

# This is documentary only; run `docker -p` to actually expose ports.
EXPOSE 22 51234

# This configuration runs SSHD as pid 1.  You then connect to the
# container as `maptool` using a public key.  This will give a command
# prompt from which you can execute MapTool (use X11 forwarding).
# Now load a campaign file and start the server.  Players can connect to this
# container, port 51234, to get to this MapTool server.  However, that port is
# only open on `localhost`, so they will also need to SSH in and forward a local
# port to the 51234 remote port.  When they start their local MapTool and connect
# to their local port, it'll be tunneled over the SSH link to this MapTool.

# For diagnostics & testing, if needed.
# This is near the end of the Dockerfile so that earlier images don't have to
# be rebuilt if these lines change.  This is important because installing all
# of the GUI libs into the "minimal" image takes a fair amount of time.
#RUN apt update && apt install -y net-tools tcpdump ethtool nano

# If you want to start MapTool directly, more s/w support is needed.
# {
    # There would need to be a framebuffer device that MapTool could use as its
    # display device, and the environment would need to be populated so that when
    # MapTool is executed, it knows to use that device.  (I haven't done this
    # yet, and I believe it'll take a bit of tinkering to get it right.  A
    # display manager is needed, such as `gdm`, and it would need to be
    # configured to autologin as `maptool`.  Using a fb would also increase
    # the memory usage of the container.)

    # Everything from here runs as `maptool`
    #USER maptool

    # This is technically a JSON array, so double quotes are required around
    # strings.
    #ENTRYPOINT ["/opt/maptool/bin/MapTool"]
# } else {
    # This just runs SSHD so you can login to the container and try stuff out.
    # After logging in, try executing "/opt/maptool/bin/MapTool" with a local
    # X server running and X11 forwarding turned on in your SSH client. :)
    CMD ["/usr/sbin/sshd", "-D"]
# }
