# Copyright (c) 2012-2016 Codenvy, S.A.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
# Contributors:
# Codenvy, S.A. - initial API and implementation

FROM eclipse/stack-base:ubuntu

RUN sudo apt-get update && \
    sudo apt-get install -y --no-install-recommends supervisor x11vnc xvfb net-tools blackbox rxvt-unicode xfonts-terminus libxi6 libgconf-2-4 build-essential postgresql-client postgresql-contrib libpq-dev libmagickwand-dev qt5-default libqt5webkit5-dev gstreamer1.0-plugins-base gstreamer1.0-tools gstreamer1.0-x

# download and install noVNC

RUN sudo mkdir -p /opt/noVNC/utils/websockify && \
    wget -qO- "http://github.com/kanaka/noVNC/tarball/master" | sudo tar -zx --strip-components=1 -C /opt/noVNC && \
    wget -qO- "https://github.com/kanaka/websockify/tarball/master" | sudo tar -zx --strip-components=1 -C /opt/noVNC/utils/websockify

ADD index.html /opt/noVNC/

RUN sudo mkdir -p /etc/X11/blackbox && \
    echo "[begin] (Blackbox) \n [exec] (Terminal)     {urxvt -fn "xft:Terminus:size=12"} \n [end]" | sudo tee -a /etc/X11/blackbox/blackbox-menu

RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN curl -sSL https://get.rvm.io | bash -s stable

RUN /bin/bash -c "source /home/user/.rvm/scripts/rvm"
RUN /bin/bash --login -c "rvm install ruby-2.3.3"

RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash
RUN /bin/bash --login -c "source ~/.bashrc"
RUN /bin/bash --login -c "nvm install 6.11.2"
RUN /bin/bash --login -c "npm install -g phantomjs"

USER root
WORKDIR /usr/local
RUN wget https://download.jetbrains.com/ruby/RubyMine-2017.2.tar.gz
RUN tar -xvzf RubyMine-2017.2.tar.gz
RUN rm RubyMine-2017.2.tar.gz
USER user
WORKDIR /projects


ADD supervisord.conf /opt/
EXPOSE 6080
CMD /usr/bin/supervisord -c /opt/supervisord.conf && tail -f /dev/null
