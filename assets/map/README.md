# Base map styles

`colorful.json` (light) and `eclipse.json` (dark) are the VersaTiles
Shortbread styles that OpenStreetMap publishes for its vector tiles
(CC0, per each style's `metadata.license`). `sprites@2x.*` is their
`basics` icon sheet.

They are bundled because vector.openstreetmap.org sends CORS headers only
for tiles, so the web build cannot read the styles, sprites or fonts from
there. On Android, Mapigrade (MapLibre Native) uses them too, so land and
roads draw without waiting for a style download; it adds OpenStreetMap's
`glyphs` URL back at runtime, because MapLibre needs fonts for labels. The
tiles themselves still load from vector.openstreetmap.org.

Changes from upstream: `glyphs` removed (labels use the system font),
`sprite` points at the bundled sheet, and the `basics:` icon prefix is
dropped because flutter_map_vector_tiles reads only a single sprite.

Regenerate (`$s` is `colorful` or `eclipse`):

```sh
curl -s https://vector.openstreetmap.org/styles/shortbread/$s.json \
  | jq -c 'del(.glyphs) | .sprite = "sprites"
      | walk(if type == "string" and startswith("basics:")
             then ltrimstr("basics:") else . end)' > $s.json
curl -sO https://vector.openstreetmap.org/styles/shortbread/sprites/basics/sprites@2x.json
curl -sO https://vector.openstreetmap.org/styles/shortbread/sprites/basics/sprites@2x.png
```

When OpenStreetMap moves to a new Shortbread version, the tile URL in
both styles changes with it.
