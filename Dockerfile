# This is a "minimal" Ubuntu per https://ubuntu.com/blog/minimal-ubuntu-released
# Only 29MB in size and optimized for AWS and GCloud!  Cool. ;)
FROM ubuntu:18.04
RUN groupadd maptool && useradd -m maptool -g maptool -G adm,cdrom,sambashare,sudo

# Creates directory, if needed.
WORKDIR /home/maptool/.ssh
COPY . .

# Have to do this as `root` so we can append to /etc/ssh/sshd_config
RUN chown maptool:maptool . && \
    chmod 700 . && \
    cat sshd_config.inc >> /etc/ssh/sshd_config

# Everything from here runs as `maptool`
USER maptool


# We might need to install openssh-server and/or pandoc...
# (Not with the ubuntu:minimal image, as it contains SSH.)
#RUN apt install openssh-server
#RUN apt install pandoc

# Download and install a release of MapTool.
#
# This retrieves a JSON object describing the latest release, then looks for
# the asset that ends with '.deb"' (which will be the Debian install package).
# Using both `grep` and `cut` is overkill since `awk` can do both, but this is
# copy/pasted from StackOverflow so I'm being lazy. :)
#RUN curl -L $(curl -s https://api.github.com/repos/RPTools/maptool/releases/latest | grep 'browser_.*[.]deb"' | cut -d\" -f4)

# This grabs a particular release.
RUN curl -L https://github.com/RPTools/maptool/releases/download/1.9.2/maptool_1.9.2-amd64.deb
RUN dpkg -i maptool_*.deb

# Regardless of which one is used, copy the `.desktop` file to the right place.
RUN cp /opt/maptool/lib/*.desktop /home/maptool/.local/share/applications

# This is documentary only; run `docker -P` to actually expose the port.
EXPOSE 51234

# This is technically a JSON array, so double quotes are required.
#ENTRYPOINT ["/opt/maptool/bin/MapTool"]
#CMD ["--help"]
