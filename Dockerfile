FROM ubuntu:xenial

# non-interactive mode for building the image
ARG DEBIAN_FRONTEND=noninteractive

# update first
RUN apt-get update && apt-get upgrade -y

# install some basic dependencies
RUN apt-get install curl apt-transport-https software-properties-common git -y

# add matrix repo key
RUN curl -s http://matrix.org/packages/debian/repo-key.asc | apt-key add -

# add matrix repo
RUN apt-add-repository "deb http://matrix.org/packages/debian xenial main"

# specify wanted synapse version here!
ENV SYNAPSE_VERSION 0.25.1-1

# update repos and install synapse
RUN apt-get update && apt-get install matrix-synapse=${SYNAPSE_VERSION} libpq-dev python-pip -y && pip install psycopg2

# add github kamax-io/matrix-synapse-rest-auth to enable custom authentication backends
RUN curl -s https://raw.githubusercontent.com/kamax-io/matrix-synapse-rest-auth/v0.1.1/rest_auth_provider.py > /usr/lib/python2.7/dist-packages/rest_auth_provider.py

# config and keys
VOLUME [ "/etc/custom-matrix" ]
# upload data and logs
VOLUME [ "/data/media_store", "/data/uploads", "/data/logs" ]

# federation (s2s)
EXPOSE 8448
# client (c2s)
EXPOSE 8008

# run synapse in foreground mode
CMD ["python", "-B", "-m", "synapse.app.homeserver", "-c", "/etc/custom-matrix/homeserver.yaml"]
