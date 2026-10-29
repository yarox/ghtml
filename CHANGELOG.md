# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- Element interpolation: `{@element expr}` inserts an `Element(msg)`, `{@elements expr}` inserts a `List(Element(msg))` (composition, `children` parameters)
- Keyed loops: `{#each items as item (key)}` and `{#each items as item, i (key)}` use `keyed.fragment` with the given `String` key
- SVG: elements inside `<svg>` are created in the SVG namespace with `element.namespaced` (tag names such as `linearGradient` keep their case); `<foreignObject>` holds HTML again

### Fixed
- `style="..."`, `width="..."` and `height="..."` generated calls that did not compile (`attribute.style` takes two arguments, `attribute.width`/`height` take an `Int`). They now use `attribute.attribute(name, value)`; interpolated values are `String`, as for other attributes
- A boolean attribute with a written value (`disabled="disabled"`) generated `attribute.disabled("disabled")`, which did not compile

### Changed
- **Breaking:** `{#each}` without a key is no longer keyed. It generates `fragment(list.map(...))`. Before, it used `item.id` as the key (so lists of strings did not compile), or the index when an index was given. After upgrading, run `gleam run -m ghtml -- force`, because the cache only checks the template content.
- An unused loop index is prefixed with `_`, and `gleam/int` is imported for index loops only when the template uses `int.`, so the generated code has no warnings

## [0.1.1] - 2026-02-01

### Fixed
- Fixed broken images and GIFs on HexDocs by using absolute GitHub URLs

## [0.1.0] - 2026-02-01

### Added
- Initial release
- Template syntax: `@import`, `@params`, expression interpolation `{expr}`
- Control flow: `{#if}`, `{#each}`, `{#case}` blocks
- Event handlers: `@click`, `@input`, `@change`, `@submit`, etc.
- Attribute support: static, dynamic, and boolean attributes
- Custom element support (tags with hyphens use `element()`)
- Watch mode (`--watch`) for automatic regeneration during development
- Hash-based caching for incremental builds
- Orphan file cleanup (`--clean`)
- Force regeneration (`--force`)
