# we use mongo client to connect
FROM mongo:3.6

# info
LABEL maintainer="heyarny@github"

# copy the shell script
COPY mongo_setup.sh /
RUN chmod +x /mongo_setup.sh

# start setup
CMD ["/mongo_setup.sh"]
