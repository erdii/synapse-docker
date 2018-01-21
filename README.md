# synapse-docker

OMFG what am I doing here?

## Synapse version
edit this line in the Dockerfile: `ENV SYNAPSE_VERSION yourversionhere`

## Volumes
* `/etc/custom-matrix/`
  * homeserver.yaml
  * yourdomain.com.log.config
  * yourdomain.com.signing.key
  * yourdomain.com.tls.crt
  * yourdomain.com.tls.dh
  * yourdomain.com.tls.key
* `/data/logs`: logging data
* `/data/media_store`: user uploads
* `/data/uploads`: ongoing user uploads

## Usage

```
# bootstrap volumes (leave this running)
docker run \
  -v synapse_cfg:/etc/custom-matrix \
  -v synapse_media_store:/data/media_store \
  -v synapse_uploads:/data/uploads \
  -v synapse_logs:/data/logs \
  --name helper \
  -it --rm synapse:0.25.1-1 bash

# now open a new terminal and copy the config and optionally the existing media_store into the config volume
docker cp synapse_cfg/* helper:/etc/custom-matrix/

# now close the helper container (ctrl + c)
# and create the production container
docker run \
  --link postgres-container \
  --link auth-container-is-optional \
  -p 8008:8008 \
  -p 8448:8448 \
  -v synapse_cfg:/etc/custom-matrix \
  -v synapse_media_store:/data/media_store \
  -v synapse_uploads:/data/uploads \
  -v synapse_logs:/data/logs \
  --ulimit nofile=15000:15000 \
  --name synapse \
  -d synapse:0.25.1-1
```

## Configuration

```
# Database configuration
database:
  name: psycopg2
  args:
    user: "<POSTGRES_USER>"
    password: "<POSTGRES_PASS>"
    database: "<POSTGRES_DATABASE>"
    host: "postgres"
    cp_min: 5
    cp_max: 10

# custom REST auth provider
password_providers:
  - module: "rest_auth_provider.RestAuthProvider"
    config:
      endpoint: "http://auth-container-is-optional:9866"
```

