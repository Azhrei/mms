# This is a "minimal" Ubuntu per https://ubuntu.com/blog/minimal-ubuntu-released
# Only 29MB in size and optimized for AWS and GCloud!  Cool. ;)
#
# However, this configuration installs MapTool and all of its dependents so
# that it can be executed locally within the container.  This bloats the size
# of the image up to ~3GB.
#
# With just a few tweaks, this container can instead be a simple tunneling
# tool that routes players through the container to the host's MapTool server.
FROM ubuntu:18.04
RUN apt update && \
    apt install -y openssh-server curl sudo
# This is because `sshd` requires `/run/sshd` to exist.
# See https://askubuntu.com/a/1110843/531533
RUN mkdir -p -m0755 /var/run/sshd

# The `tzdata` pkg is (eventually) needed for the `ubuntu-desktop` package.
# Note that its installation is interactive, hence piping data into it.
RUN apt update && \
    echo -e "\n12\n5" | apt install -y tzdata
RUN groupadd maptool && \
    useradd -m maptool -g maptool -G adm,cdrom && \
    chsh -s /bin/bash maptool

# Need to install a full GUI if we want to run MapTool inside the container.
RUN apt update && \
    apt install -y ubuntu-desktop xdg-utils

# Creates directory, if needed.
WORKDIR /home/maptool/.ssh

# Download and install a release of MapTool.
# This needs to be parameterized at the time the image is built.
#
# This retrieves a JSON object describing the latest release, then looks for
# the asset that ends with '.deb"' (which will be the Debian install package).
# Using both `grep` and `cut` is overkill since `awk` can do both, but this is
# copy/pasted from StackOverflow and I'm being lazy. :)
#RUN curl -L $(curl -s https://api.github.com/repos/RPTools/maptool/releases/latest | grep 'browser_.*[.]deb"' | cut -d\" -f4)

# This grabs a particular release.
RUN curl -LO https://github.com/RPTools/maptool/releases/download/1.9.2/maptool_1.9.2-amd64.deb
RUN dpkg -i maptool_*.deb && \
    rm maptool_*.deb

# Copy the `.desktop` file to the right place.
RUN mkdir -p /home/maptool/.local/share/applications && \
    cp /opt/maptool/lib/*.desktop /home/maptool/.local/share/applications

COPY . .
RUN chown -R maptool:maptool /home/maptool && \
    chmod 700 . && \
    cat sshd_config.inc >> /etc/ssh/sshd_config && \
    cp maptool.sudo /etc/sudoers.d/maptool

# This is documentary only; run `docker -P` to actually expose these ports.
EXPOSE 22 51234

# This configuration runs the SSH daemon as pid 1.  You then connect to the
# container as `maptool` using the public key for `_mtadmin`.  This will give
# a command prompt from which you can execute MapTool (use X11 forwarding).
# Now load a campaign file and start the server.  Players can connect to this
# container, port 51234, to get to this MapTool server.  However, that port is
# only open on `localhost`, so they'll need to SSH in and forward a local port
# to the 51234 remote port.  When they start their MapTool and connect to
# their local port, it'll be tunneled over the SSH link to this MapTool.

# For diagnostics & testing, if needed.
#RUN apt update && apt install -y net-tools tcpdump ethtool nano

# If you want to start MapTool directly, more s/w support is needed.
# {
    # There would need to be a framebuffer device that MapTool could use as its
    # display device, and the environment would need to be populated so that when
    # MapTool is executed, it knows to use that device.  (I haven't done this
    # yet, and I believe it'll take a bit of tinkering to get it right.  A
    # display manager is needed, such as `gdm`, and it would need to be
    # configured to autologin as `maptool`.)

    # Everything from here runs as `maptool`
    #USER maptool

    # This is technically a JSON array, so double quotes are required.
    #ENTRYPOINT ["/opt/maptool/bin/MapTool"]
# } else {
    CMD ["/usr/sbin/sshd", "-D"]
# }
