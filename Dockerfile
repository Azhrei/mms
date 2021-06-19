FROM ubuntu:latest
RUN useradd -m maptool -G sudo
RUN mkdir ~maptool/.ssh
RUN chmod 700 ~maptool/.ssh
COPY . ~/maptool/.ssh

# We might need to install openssh-server and/or pandoc...
#RUN apt install openssh-server
#RUN apt install pandoc
