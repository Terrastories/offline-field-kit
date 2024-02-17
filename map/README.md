# Custom Map Packages

By default, this fieldkit utilizes our default Terrastories Map package. If you want to configure the use of a custom map package, this README will show you how to configure it.

> *For information on creating your own custom map package, please see our [Preparing offline map packages](https://docs.terrastories.app/operating-terrastories-offline/preparing-offline-map-packages) documentation.*

## Prerequisites

Before you begin, ensure that you have a Custom Map Package generated. This should include your tiles in `.pmtiles` or `.mbtiles` format, a `style.json` configuration, and any relevant sprites and fonts.

## Adding Custom Map Packages

You may add as many map packages to Terrastories as you want, but they must adhere to the following conditions:

1. Your tiles must be in compressed `mbtiles` or `pmtiles` single-file archive format.
2. Your package must include all fonts used in your map style.
3. Your package may contain sprites.
4. Your map package must include your style specifications in `style.json` and tiles in `tiles.pmtiles` or `tiles.mbtiles`. These files must be available at the root of the `data` folder:
    ```
    data/
    ├── fonts/
    │   └── Font Name/
    │       ├── font.pbf
    │       └── ...
    ├── sprites/
    │   ├── sprite.png
    │   └── ...
    ├── tiles.pmtiles
    ├── tiles.mbtiles
    ├── style.json
    └── config.json
    ```
5. Your style specification must include reference the name of your style:
    ```json
    {
      "sources": {
        "terrastories-map": { // This MUST be terrastories-map OR you MUST update the config.json file (see below)
          "type": "vector",
          "url": "pmtiles://tiles.pmtiles" // or "mbtiles://tiles.mbtiles
        }
      },
      "sprite": "sprite", // optional, only needed if your style utilizes sprites by name
      "glyphs": "{fontstack}/{range}.pbf",
      // the rest of your style specifications
    }
    ```
    *NOTE: Protomaps PMTiles Protocol currently does not support sprites. This feature is coming soon.*

In the future, we hope to streamline this process for you. For now, if you have any questions on how to configure your maps, please reach out to the Terrastories stewards team.

## Configuring Tileserver (config.json)

We provide a preconfigured `config.json` to serve your style; however, some changes may need to be made depending on your package.

### Different filename for style configuration

By default, we assume your style is stored in a file called `style.json`. If this is not correct, you'll need to correctly reference the file in `config.json`:

```json
{
  "styles": {
    "terrastories-map": {
      "style": "style.json", // change `style.json` to the name of yours, including path if necessary.
      "tilejson": {
        "type": "overlay"
      }
    }
  }
}
```

### Style references external source data or using {handlebars} notation

If your style source is setup to reference a fully qualified URL, this URL must be accessible *offline*. While it may work if you have an internet connection, it will *not* work offline unless your server is configured to serve at that url. We recommend you use a locally stored single-file archive instead.

If your style source looks something like this:

 ```json
    {
      "sources": {
        "terrastories-map": {
          "type": "vector",
          "url": "pmtiles://{my-source}" // <-- change to configuration above, or update config.json
        }
      }
    }
```
If you wish to keep using handlebar source reference, update the `config.json` to include your data source:

```json
{
  "options": {
    // tileserver options
  },
  "data": {
    "my-source": {
      "pmtiles": "tiles.pmtiles"
    }
  },
  "styles": {
    // your style config
  }
}
```

This will correctly infer your data source. Be sure to restart your Tileserver service after making changes.

## Configuring Terrastories to use your custom map package

Once you have your map package configured and placed in the appropriate file structure, you'll need to tell Terrastories to use your map package.

In [`compose.yaml`](../compose.yaml), find the `tileserver` service and uncomment the two lines as specified. The service should look like this when you're done:

```yaml
# in compose.yaml
  tileserver:
    restart: unless-stopped
    image: terrastories/terrastories-map:latest
    ports:
      - 8080:8080
    ### UNCOMMENT THE NEXT TWO LINES IF YOU WANT TO USE A CUSTOM MAP PACKAGE
    volumes:
      - ./map/data:/data:ro
```
> This tells Docker to boot your Terrastories instance with your custom map configuration.

Restart your Terrastories instance for the changes to take effect.

## Reverting back to default map package

If you wish to revert back to using the default Terrastories Map package, stop your Terrastories instance and comment the two lines that you uncommented when you originally set up your custom map package in `compose.yaml`:

```yaml
  tileserver:
    restart: unless-stopped
    image: terrastories/terrastories-map:latest
    ports:
      - 8080:8080
    ### UNCOMMENT THE NEXT TWO LINES IF YOU WANT TO USE A CUSTOM MAP PACKAGE
    # volumes:
    #  - ./map/data:/data:ro
```

Save the file and restart your instance: `docker compose up`.

> Note: You can leave your package configuration in place; reverting back to the default map package does not require you to remove your map configuration — allowing you the flexibility to swap back and forth with ease.

## Advanced Configuration

### Changing the name of your style

By default, tileserver is configured to serve your style with the name `terrastories-map`. We recommend you keep this configuration as it will automatically work with your Terrastories instance with no further configuration.

If you wish to change that, you'll need to make a couple of additional changes:

1. Update the `config.json` file and change the instances of `terrastories-map` to the style name of choice.
1. Update [`.env`](../.env) to set `TILESERVER_URL` to the URL of your new style. It will likely look something like so:
   http://terrastories.local:8080/styles/[YOUR SOURCE NAME HERE]/style.json
1. Ensure you restart both your Terrastories and Tileserver services.
