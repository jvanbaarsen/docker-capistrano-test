# Use phusion/baseimage as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/passenger-ruby21:0.9.12
MAINTAINER  Jeroen van Baarsen "jeroen@firmhouse.com"

# Set correct environment variables.
ENV HOME /root

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh


# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Add the nginx info
ADD webapp.conf /etc/nginx/sites-enabled/webapp.conf

# Enable insecure ssh connection TODO: Remove in production
RUN /usr/sbin/enable_insecure_key

# Prepare folders
RUN mkdir /home/app/www
RUN mkdir /home/app/bundle
RUN chown -R app:app /home/app/www
RUN chown -R app:app /home/app/bundle

# Run Bundle in a cache efficient way
ADD Gemfile      /home/app/www/
ADD Gemfile.lock /home/app/www/
RUN cd /home/app/www && sudo -u app -H bundle install --deployment --path /home/app/bundle

# Add the rails app
ADD . /home/app/www

# Start Nginx / Passenger
RUN rm -f /etc/service/nginx/down

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 80
EXPOSE 22
