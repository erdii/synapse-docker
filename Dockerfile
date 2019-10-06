FROM ubuntu:xenial

# non-interactive mode for building the image
ARG DEBIAN_FRONTEND=noninteractive

# update first
RUN apt-get update && apt-get upgrade -y

# install some basic dependencies
RUN apt-get install curl apt-transport-https software-properties-common git -y

# add matrix repo key
RUN curl -s -o /usr/share/keyrings/matrix-org-archive-keyring.gpg https://packages.matrix.org/debian/matrix-org-archive-keyring.gpg

# add matrix repo
RUN echo "deb [signed-by=/usr/share/keyrings/matrix-org-archive-keyring.gpg] https://packages.matrix.org/debian/ $(lsb_release -cs) main" \
		| tee /etc/apt/sources.list.d/matrix-org.list

# specify wanted synapse version here!
ENV SYNAPSE_VERSION 1.4.0+xenial1

# update repos and install synapse
RUN apt-get update && apt-get install matrix-synapse-py3=${SYNAPSE_VERSION} libpq-dev python-pip -y && pip install psycopg2

# add github kamax-io/matrix-synapse-rest-auth to enable custom authentication backends
RUN curl -s https://raw.githubusercontent.com/kamax-io/matrix-synapse-rest-auth/v0.1.2/rest_auth_provider.py > /opt/venvs/matrix-synapse/lib/python3.5/site-packages/rest_auth_provider.py

# config and keys
VOLUME [ "/etc/custom-matrix" ]
# upload data and logs
VOLUME [ "/data/media_store", "/data/uploads", "/data/logs" ]

# federation (s2s)
EXPOSE 8448
# client (c2s)
EXPOSE 8008

# run synapse in foreground mode
CMD ["/opt/venvs/matrix-synapse/bin/python", "-B", "-m", "synapse.app.homeserver", "-c", "/etc/custom-matrix/homeserver.yaml"]
