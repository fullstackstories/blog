FROM ruby:2.5.3

ENV DEBIAN_FRONTEND noninteractive

ARG SSH_KEY_PRIV
ARG SSH_KEY_PUB

RUN mkdir /root/.ssh/ && echo "$SSH_KEY_PRIV" > /root/.ssh/id_rsa && echo "$SSH_KEY_PUB" > /root/.ssh/id_rsa.pub && \
    mkdir -p /usr/src/app && \ 
    adduser --shell /bin/sh --uid 10001 --ingroup root --gecos "" --disabled-password --home /home/jekyll jekyll && \
    chown -R jekyll /usr/src/app && \
    ssh-keyscan -H github.com >> /root/.ssh/known_hosts && \
    ssh-keyscan -H bitbucket.org >> /root/.ssh/known_hosts && \
    chmod 600 /root/.ssh/id_rsa && \
    chmod 700 /root/.ssh && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -yqq yarn && \
    apt-get install -yqq --no-install-recommends nodejs && \
    apt-get install -yqq locales && \
    apt-get clean && rm -r /var/lib/apt/lists
WORKDIR /usr/src/app

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV BUNDLE_PATH="/gems"
COPY Gemfile* /usr/src/app/
RUN bundle install && gem install jekyll

USER jekyll
RUN echo 'require "irb/ext/save-history"' >> ~/.irbrc; \
    echo IRB.conf[:SAVE_HISTORY] = 100 >> ~/.irbrc; \
    echo 'IRB.conf[:HISTORY_FILE] = ENV["HOME"] + "/.irb-history"' >> ~/.irbrc

CMD ["bundle", "exec", "jekyll", "serve"]

