# Map Packages

All map packages in this folder are loaded into Terrastories.

Each map package is referenced by the folder name inside /map. Given the following directory structure:

```
map/
├── terrastories-map/
└── your-style-name/
```

You can configure which map package is accessed by specifying the style name in `OFFLINE_MAP_STYLE`:

```
# our default
OFFLINE_MAP_STYLE=terrastories-map

# your custom
OFFLINE_MAP_STYLE=your-style-name
```

## Using our default Map Package

Everything except our tiles is contained in this repository. To use our default map package:

1. [Download our tiles](https://bit.ly/45LGigh)
2. Place it in the `terrastories-map` folder (terrastories-map/tiles.pmtiles)

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
4. Your style specification must include fully-qualified URLs to your pmtiles, font glyphs, and sprites (if included):
    ```json
    {
      "sources": {
        "your-source-name": {
          "type": "vector",
          "url": "http://terrastories.local/map/your-style-name/tiles.pmtiles"
        }
      },
      "sprite": "http://terrastories.local/map/your-style-name/sprites/sprite",
      "glyphs": "http://terrastories.local/map/your-style-name/fonts/{fontstack}/{range}.pbf",
      // the rest of your style specifications
    }
    ```

In the future, we hope to streamline this process for you. For now, if you have any questions on how to configure your maps, please reach out to the Terrastories stewards team.