# Terrastories Offline "Field Kit"

This repository is your one-stop shop for configuring and running a production-ready instance of Terrastories, completely disconnected from the internet.

> While Terrastories can run offline once on your field kit, you will need a stable internet connection to setup and configure your instance.

## Supported Tags

- v2.0.0, latest

**Supported architectures:** ([more info](https://github.com/docker-library/official-images#architectures-other-than-amd64))

linux/amd64, linux/arm64, linux/arm/v7

## Getting Started

### Prerequisites

- [**Docker Desktop**](https://docs.docker.com/desktop/install/linux-install/): This installs the Docker Engine and Compose V2.

### Quick Start

1. Set up your [Map Package](map/README.md) configuration.
1. Update your `/etc/hosts` file to include:

   ```
   127.0.0.1 terrastories.local
   ```

   This will allow you to access Terrastories from this URL.
1. Run:

   `docker compose up`

   This will download the latest production-ready image and boot a fully configured Terrastories instance, database, and tileserver.

## Advanced Setup

If you're familiar with working with Docker images, you can configure your database, volumes, tileserver, local host name, and more.

### How to extend your image

> Note: Some image extensions are required to run if you do not utilize the provided compose file. These are marked by `(Required)` next to the extension name.

**DATABASE_URL** (Required)

This must be a fully-qualified postgresql url to a database of your choice. It must be accessible to your device's local network.

**RAILS_ENV** (Required)

This should be set to `offline`. By default, it sets the environment to our online `production` version.

**OFFLINE_MAP_STYLE**

This must be the style name of a protomap archived pmtiles style. See [map configuration](map/README.md) for how to set up custom map packages. Our default maps are available in this repository under the /map folder, which are free to use. Dwnload the [tiles.pmtiles](https://bit.ly/45LGigh) and place the file in the folder according to the instructions.

**USE_PROTOMAPS**

If you want Terrastories to load your map package in OFFILNE_MAP_STYLE, you must set USE_PROTOMAPS to any value.

**TILESERVER_URL**

This must be a fully-qualified url to your [prepared offline maps](https://docs.terrastories.app/setting-up-a-terrastories-server/preparing-offline-maps) hosted on a locally accessible Tileserver.

Your Tileserver must allow CORS from terrastories.local or any origin.

**HOST_HOSTNAME**

Terrastories will always surface `terrastories.local` as an accessible domain.

You may customize the domain by setting it to the `HOST_HOSTNAME` variable. It's best practice to utilize a "domain" that would not otherwise be accessible when connected to the domain.

**PORT**

Similarly, you may customize your PORT. By default, this is configured to be `3000`. Be sure to correctly port map when you boot your instance if you wish to access Terrastories by the hostname without a port.

**SECRET_KEY_BASE**

This is used by Rails to generate keys for encrypted messages and more. If you are migrating from an existing instance and wish to keep the same secret, you can set it here.

Otherwise, when correctly booted into the `offline` environment, our application will automatically generate a unique key for your instance. It will also be stored in a file for the application to reuse so long as the container is not torn down.

**AUTO_RUN_MIGRATIONS**

Default: `yes` (recommended).

When set to `yes`, we will attempt to prepare your database with the schema and migrations available in the image. Any other input disables this setting.

For a new database, it will load your schema and run any migrations not included in the initial schema.

For an existing database, it will run any pending migrations.

### Link the required local storage files

#### Media Storage

Assets that are uploaded to the instance need to be stored somewhere. At the moment, this must be a locally acccessible file folder.

Your folder must be mapped to: `/media` via a Docker volume.

#### Import Media

Assets that are referenced in import CSV files can be provided via a local folder. When mapped, the importer will attempt to find and utilize those referenced assets.

Your folder must be mapped to: `/api/import/media` via a Docker volume.

### Link static Protomaps (pmtiles) folder for maps

If you wish to make use of our free OFFLINE_MAP_STYLE protomaps, you must set up the map package or follow the instructions in [maps](map/README.md).

Once set up, you must map the volume to: `/api/public/map` via a Docker volume. We recommend configuring this to a readonly volume (:ro).

### And run with Docker

```sh
docker run
  -it
  -p 80:3000
  -e RAILS_ENV=offline
  -e DATABASE_URL=postgresql://user:pass@host:5432/terrastories
  -e TILESERVER_URL=http://localhost:8080/styles/your-style-name/style.json
  -v $(pwd)/media:/media
  -v $(pwd)/import:/api/import/media
  -v $(pwd)/map:/api/public/map:ro
  --name terrastories-field-kit
  terrastories/terrastories:latest
```

#### Or with Docker Compose

Create a `compose.yaml` file:

```yaml
services:
  web:
    image: terrastories/terrastories:latest
    ports:
      - 80:3000
    environment:
      - RAILS_ENV=offline
      - HOST_HOSTNAME=terrastories.local
      - TILESERVER_URL=http://localhost:8080/styles/your-style-name/style.json
      - DATABASE_URL=postgresql://user:pass@host:5432/terrastories
    volumes:
      - ./media:/media
      - ./import:/api/import/media
      - ./map:/api/public/map:ro
```

and run `docker compose up` with your custom configuration.

## Need help?

- Read our [documentation](https://docs.terrastories.app/), particularly our ["hosting offline" guide](https://docs.terrastories.app/setting-up-a-terrastories-server/hosting-environments/hosting-terrastories-offline-as-a-field-kit).
- Join us on [Ruby for Good Slack](https://rubyforgood.org/join-us) and join the #terrastories channel.

## Find an issue?

If you have an issue with running the "Quick Start" instructions, please open an issue [here](https://github.com/Terrastories/offline-field-kit/issues).

If you run into an issue when running Terrastories once its booted, please open an issue [here](https://github.com/Terrastories/terrastories/issues).

While we do not officially support custom setups, we do encourage you to ask questions!