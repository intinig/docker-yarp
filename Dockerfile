FROM ubuntu:14.04
MAINTAINER Giovanni Intini <giovanni@mikamai.com>

ENV REFRESHED_AT 2015-01-08

RUN apt-get -yqq update
RUN apt-get install -yqq autoconf \
                         build-essential \
                         libreadline-dev \
                         libpq-dev \
                         libssl-dev \
                         libxml2-dev \
                         libyaml-dev \
                         libffi-dev \
                         zlib1g-dev \
                         git-core \
                         curl \
                         node \
                         libmagickcore-dev \
                         libmagickwand-dev \
                         libcurl4-openssl-dev \
                         bison \
                         ruby

# RUN apt-get install -yqq imagemagick
		# libbz2-dev \
		# libevent-dev \
		# libffi-dev \
		# libglib2.0-dev \
		# libncurses-dev \
		# libxslt-dev \
                # procps \

RUN rm -rf /var/lib/apt/lists/*

ENV RUBY_MAJOR 2.1
ENV RUBY_VERSION 2.1.5

RUN mkdir -p /usr/src/ruby

RUN curl -SL "http://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.bz2" \
		| tar -xjC /usr/src/ruby --strip-components=1

RUN cd /usr/src/ruby && autoconf && ./configure --disable-install-doc && make -j"$(nproc)"

RUN apt-get purge -y --auto-remove bison \
                                   ruby

RUN cd /usr/src/ruby && make install && rm -rf /usr/src/ruby

RUN echo 'gem: --no-rdoc --no-ri' >> $HOME/.gemrc
RUN gem install bundler
RUN bundle config path /app/vendor/remote_gems

RUN git clone https://github.com/mezis/yarp.git /app
WORKDIR /app

RUN bundle install --deployment

ADD .env /app/.env

EXPOSE 24591
EXPOSE 9292

VOLUME /app
VOLUME /tmp

ENV RACK_ENV production
ENV MEMCACHIER_SERVERS memcached:11211

CMD ["bundle", "exec", "foreman", "start"]
