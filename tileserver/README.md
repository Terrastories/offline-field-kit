# Tileserver GL

A server that serves map tiles is required to run Terrastories. Online, this is usually delegated to mapping solutions such as Mapbox, OpenStreetMap, and Maptiler.

In order to run Terrastories offline, we use a locally "hosted" tileserver called Tileserver-GL.

## Default Offline Maps

By default, Terrastories Offline Field Kit provides a locally bootable `tileserver` seeded with our default offline maps. This includes fonts, sprites, and the style definition.

Due to the .mbtiles file size being too large, you'll need to [download our mbtiles](https://bit.ly/39EdYoQ) and place it in the `mbtiles` folder with the name `terrastories-map.mbtiles`.

## Using a custom map style

Alternatively, you can use your own custom maps when they are prepared appropriately.

> ℹ️ Learn more about how to [prepare your map for offline use](https://docs.terrastories.app/setting-up-a-terrastories-server/preparing-offline-maps) in our docs.

There are two primary considerations when using your own maps. The first is ensuring the tileserver configuration defines the expected behavior for your style specification. The second is ensuring your style specification correctly references your assets and mbtiles given your server configuration.

### Apply your custom map configuration

If you only plan on using your custom map style AND you only have one map style to configure, your best bet is to replace the all of the style data and assets in the `data` folder with your downloaded assets and style specification.

By replacing the data with the structure from your downloaded map data, everything will already be in the correct format — no changes necessary.

> Be sure to verify the `data/config.json` file is present and correctly references your new style.

## Extending the default map configuration

If you want to add your custom map style alongside the default maps we provide OR you have multiple custom map styles you want to utilize, you'll need to ensure that you place your style assets in the correct structure and your style specification correctly references them.

### Default file structure

By default, the server configuration and style specification utilizes the following file structure:

```
data/
├── fonts/
│   └── Font Name/
│       ├── font.pbf
│       └── ...
├── mbtiles/
│   └── terrastories-map.mbtiles
├── sprites/
│   └── terrastories-map/
│       ├── sprite.png
│       └── ...
├── styles/
│   └── terrastories-map.json
└── config.json
```

### Add your custom style specification

From your map assets, extract the generated `style.json` place it in the `data/styles/` folder. **Rename this file with a unique and colloquial descriptor for your map.** This is important, as it will be what is used by your style specification references.

```diff
 data/
 ├── ...
 ├── styles/
 │   ├── terrastories-map.json
+│   └── your-style-name.json // <- give it a unique name
 └── ...
```

### Add your custom sprites

If your style uses sprites, you will need to add your sprites to your sprites folder.

1. Create a new folder _using the same name you gave your style_,
1. And place your sprites inside the created folder.

```diff
 data/
 ├── ...
 ├── sprites/
 │   ├── terrastories-map/
+│   └── your-style-name // <- same unique name
+│       ├── sprite.png
+│       └── ...
 └── ...
```

### Move your mbtiles and fonts

Your fonts can be placed directly at the root of the font folder. If your fonts are shared between styles, you can either replace the font with yours, or skip adding that specific font.

Your `.mbtiles` file should be placed at the root of the `mbtiles` folder. You're welcome to name this the same as your style to keep it consistent (and we recommend it); however, since this file is configured in the `config.json` file and referenced from there, any name will work here.

```diff
 ├── data/
 │   ├── fonts/
 │   │   ├── Font Name/
+│   │   └── Your New Font/
+│   │       ├── 0-11.pbf
+│   │       └── ...
 │   ├── mbtiles/
 │   │   ├── terrastories-map.mbtiles
+│   │   └── your-style-name.mbtiles
 │   └── ...
 └── ...
```

### Update config.json

Our default map uses the following server [configuration](data/config.json). Open this file and edit the following lines so Tileserver knows how to load your style and source data:


```diff
 {
   "options": {
     "paths": {
       "fonts": "fonts",
     "sprites": "sprites",
      "styles": "styles"
     }
   },
   "data": {
     "terrastories-map": {
       "mbtiles": "mbtiles/terrastories-map.mbtiles"
+    },
+    "your-style-name": {
+      "mbtiles": "mbtiles/your-style-name.mbtiles"
    }
   },
   "styles": {
     "terrastories-map": {
       "style": "terrastories-map.json",
       "tilejson": {
         "type": "overlay"
       }
+    },
+    "your-style-name": {
+      "style": "your-style-name.json"
+      // ... include any style options here.
     }
   }
 }
```

### Verify your style specification

Open your style `your-style-name.json` file and ensure that your fonts, sprites, and mbtiles use the appropriate references:

```diff
  {
    "version": 8,
    "name": "Your Style Name",
    "sources": {
      "your-styles-tiles": {
        "type": "raster",
+       "url": "mbtiles://{your-style-name}",
        "tileSize": 256
      }
    },
+   "sprite": "{style}/sprite",
+   "glyphs": "{fontstack}/{range}.pbf",
    "layers": [
      {
        "id": "background",
        "type": "background",
        "paint": {"background-color": "hsl(47, 26%, 88%)"}
      },
      {
        "id": "your-styles-tiles",
        "type": "raster",
        "source": "your-styles-tiles"
      }
    ],
    "id": "basic"
  }
```

## Restarting your Tileserver

Any time you make changes to your configuration, you must restart your tileserver.

If you are using the built in Docker compose set up, you can run:

`docker compose kill -s HUP tileserver`

Which will restart your service with the new configuration.
