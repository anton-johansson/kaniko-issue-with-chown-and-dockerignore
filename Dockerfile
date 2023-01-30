FROM ubuntu
RUN mkdir /opt/my-stuff
WORKDIR /opt/my-stuff
COPY --chown=www-data . .
RUN ls -la
