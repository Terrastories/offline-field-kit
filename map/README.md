# Custom Map Packages

By default, our production image includes our default Terrastories Map Package. If you want to configure a custom map package to load as the default map package, this README will show you how to configure it.

## Prerequisites

Before you begin, ensure that you have a Custom Map Package generated. This should include your `.pmtiles` archive of tiles and a `style.json` configuration. For more information on generating a Custom Map Package, see the [Terrastories docs](https://docs.terrastories.app).

## Configuration

Each map package is referenced by the folder name inside /map. Given the following directory structure:

```
map/
├── terrastories-map/
└── your-style-name/
```

You can configure which map package is accessed by specifying the style name in `DEFAULT_MAP_PACKAGE`:

```
# our default
DEFAULT_MAP_PACKAGE=terrastories-map

# your custom
DEFAULT_MAP_PACKAGE=your-style-name
```

## Adding Custom Map Packages

You may add as many map packages to Terrastories as you want, but they must adhere to the following conditions:

1. Your tiles must be in Protomaps compressed single-file `.pmtiles` archive.
2. Your package must include all fonts used in your map package. Sprites are optional.
3. Your map package must include your style specifications in `style.json` and tiles in `tiles.pmtiles`. These files must be available at the root of your package folder:
    ```
    your-style-name/
    ├── fonts/
    │   └── Font Name/
    │       ├── font.pbf
    │       └── ...
    ├── sprites/
    │   ├── sprite.png
    │   └── ...
    ├── tiles.pmtiles
    └── style.json
    ```
4. Your style specification must include fully-qualified URLs to your pmtiles and font glyphs:
    ```json
    {
      "sources": {
        "your-source-name": {
          "type": "vector",
          "url": "pmtiles:///map/your-style-name/tiles.pmtiles"
        }
      },
      "glyphs": "/map/your-style-name/fonts/{fontstack}/{range}.pbf",
      // the rest of your style specifications
    }
    ```
    *NOTE: Protomaps PMTiles Protocol currently does not support sprites. This feature is coming soon.*

In the future, we hope to streamline this process for you. For now, if you have any questions on how to configure your maps, please reach out to the Terrastories stewards team.

## Configuring Terrastories to use your Custom Map Package

> Note: Configuring a Custom Map Package soft-overwrites the prepackaged maps in your container, making our default package (`terrastories-map`) inaccessible. If you wish to revert to using our default map package, stop your server (Ctrl+C or `docker compose stop`) and then reboot without the additional configuration `docker compose up`.

Once your Map Package is available in `/map/your-package-name`, you will need to run Terrastories using this command:

```
docker compose run -e DEFAULT_MAP_PACKAGE=your-package-name -v $(pwd)/map:/api/public/map:ro --service-ports web
```

...while substituting `your-package-name` with the name of the folder in /map.

This command is similar to "docker compose up", however, it requires additional configuration:

* `-e` creates the Environment Variable DEFAULT_MAP_PACKAGE and sets your package name.
* `-v` binds the local /map folder into the container as a read only volume.
* `--service-ports` ensures that the mapped ports in compose are enabled.
