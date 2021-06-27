# This is a "minimal" Ubuntu per https://ubuntu.com/blog/minimal-ubuntu-released
# Only 29MB in size and optimized for AWS and GCloud!  Cool. ;)
FROM ubuntu:18.04
RUN apt update && apt install -y openssh-server curl sudo
# This is because `sshd` requires `/run/sshd` to exist.
# See https://askubuntu.com/a/1110843/531533
RUN mkdir -p -m0755 /var/run/sshd

# This one is (eventually) needed for the `ubuntu-desktop` package
RUN apt update && echo -e "\n12\n5" | apt install -y tzdata
RUN groupadd maptool && useradd -m maptool -g maptool -G adm,cdrom

RUN apt update && apt install -y ubuntu-desktop xdg-utils

# Creates directory, if needed.
WORKDIR /home/maptool/.ssh

# Download and install a release of MapTool.
#
# This retrieves a JSON object describing the latest release, then looks for
# the asset that ends with '.deb"' (which will be the Debian install package).
# Using both `grep` and `cut` is overkill since `awk` can do both, but this is
# copy/pasted from StackOverflow so I'm being lazy. :)
#RUN curl -L $(curl -s https://api.github.com/repos/RPTools/maptool/releases/latest | grep 'browser_.*[.]deb"' | cut -d\" -f4)

# This grabs a particular release.
RUN curl -LO https://github.com/RPTools/maptool/releases/download/1.9.2/maptool_1.9.2-amd64.deb
RUN dpkg -i maptool_*.deb && rm maptool_*.deb

# Copy the `.desktop` file to the right place.
RUN mkdir -p /home/maptool/.local/share/applications && \
    cp /opt/maptool/lib/*.desktop /home/maptool/.local/share/applications

COPY . .
RUN chown -R maptool:maptool /home/maptool && \
    chmod 700 . && \
    cat sshd_config.inc >> /etc/ssh/sshd_config && \
    cp maptool.sudo /etc/sudoers.d/maptool

# Everything from here runs as `maptool`
#USER maptool

# This is documentary only; run `docker -P` to actually expose the port.
EXPOSE 22 55555

# This is technically a JSON array, so double quotes are required.
#ENTRYPOINT ["/opt/maptool/bin/MapTool"]

# Only temporarily, for diagnostics & testing
#RUN apt update && apt install -y net-tools tcpdump ethtool

CMD ["/usr/sbin/sshd", "-D"]
