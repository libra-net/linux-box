FROM ubuntu:16.04

## System upgrade + add some requirements
RUN ( \
        apt-get update && \
        apt-get upgrade -y && \
        apt-get dist-upgrade -y && \
        apt install -y sudo lsb-release openssl bash-completion command-not-found openssh-client inetutils-ping nano locales && \
        apt-get -y autoclean && \
        apt-get -y autoremove \
    )

# UTF8 support
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Customize system-level bashrc
ADD bash.bashrc.sh /tmp
RUN cat /tmp/bash.bashrc.sh >> /etc/bash.bashrc  && \
	rm /tmp/bash.bashrc.sh

# Remove docker customization that cleans apt cache every time
# so that completion works for apt install
RUN rm /etc/apt/apt.conf.d/docker-clean

# Consider /home as a volume (to allow image switching without loosing /home user data)
VOLUME /home

# Let user running sudo
# + work around for `dpkg: unrecoverable fatal error, aborting:`
# + work around for `unknown group 'crontab' in statoverride file`
RUN ( \
        echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/user && \
        chmod 0440 /etc/sudoers.d/user && \
        sed -i '/crontab/d' /var/lib/dpkg/statoverride && \
        sed -i '/messagebus/d' /var/lib/dpkg/statoverride \
    )

# Add user
RUN useradd -d /home/user -ms /bin/bash -G sudo -p $(echo "password" | openssl passwd -1 -stdin) user
USER user
WORKDIR /home/user

# Custom init script
ADD init/*.sh /etc/
ENTRYPOINT /etc/entrypoint.sh
