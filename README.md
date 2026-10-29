<p align="center">
  <img src="https://raw.githubusercontent.com/burakcorekci/ghtml/master/assets/logo.png" alt="ghtml logo" width="200" />
</p>

<h1 align="center">ghtml</h1>

<p align="center">
  <strong>Write HTML templates. Get type-safe Gleam. Like magic.</strong> ✨
</p>

<p align="center">
  <a href="https://github.com/burakcorekci/ghtml/actions/workflows/test.yml"><img src="https://github.com/burakcorekci/ghtml/actions/workflows/test.yml/badge.svg" alt="test"></a>
  <a href="https://hex.pm/packages/ghtml"><img src="https://img.shields.io/hexpm/v/ghtml" alt="Package Version"></a>
  <a href="https://hexdocs.pm/ghtml/"><img src="https://img.shields.io/badge/hex-docs-ffaff3" alt="Hex Docs"></a>
  <a href="LICENSE"><img src="https://img.shields.io/hexpm/l/ghtml" alt="License"></a>
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/burakcorekci/ghtml/master/assets/gifs/hero.gif" alt="ghtml demo" width="90%" />
</p>

---

## The Problem

Ever found yourself writing Lustre views like this? 😩

```gleam
html.div([attribute.class("card")], [
  html.div([attribute.class("card-header")], [
    html.h1([attribute.class("title")], [text(user.name)]),
    html.span([attribute.class("badge")], [text("Admin")]),
  ]),
  html.div([attribute.class("card-body")], [
    html.p([], [text(description)]),
    // wait, did I close all the brackets...?
  ]),  // <-- is this right?
])     // <-- or this one?
```

Bracket-counting nightmares. We've all been there. 🤯

## The Solution

Write this instead:

```html
@params(user: User, description: String)

<div class="card">
  <div class="card-header">
    <h1 class="title">{user.name}</h1>
    <span class="badge">Admin</span>
  </div>
  <div class="card-body">
    <p>{description}</p>
  </div>
</div>
```

Run `gleam run -m ghtml` and boom — you get a perfectly formatted, type-safe Gleam module. 🎉

---

## Quick Start

**1. Install**

```sh
gleam add ghtml@1
```

**2. Create a template**

Create `src/components/greeting.ghtml`:

```html
@params(name: String)

<div class="greeting">
  <h1>Hello, {name}!</h1>
</div>
```

**3. Generate**

```sh
gleam run -m ghtml
```

**4. Use it**

```gleam
import components/greeting

pub fn view(model: Model) -> Element(Msg) {
  greeting.render(model.name)
}
```

That's it. You're done. Go grab a coffee. ☕

---

## Features

### ⚡ Blazing Fast

Hash-based caching means we only rebuild what changed. Run it a thousand times — if nothing changed, nothing rebuilds.

<p align="center">
  <img src="https://raw.githubusercontent.com/burakcorekci/ghtml/master/assets/gifs/features.gif" alt="Hash-based caching demo" width="90%" />
</p>

### 👀 Watch Mode

Change a file. Blink. It's regenerated. Your flow stays unbroken.

<p align="center">
  <img src="https://raw.githubusercontent.com/burakcorekci/ghtml/master/assets/gifs/watch.gif" alt="Watch mode demo" width="90%" />
</p>

### 🎯 Control Flow

`{#if}`, `{#each}`, `{#case}` — all the control flow you need, right in your templates.

```html
{#if user.is_admin}
  <span class="badge">Admin</span>
{/if}

{#each items as item}
  <li>{item}</li>
{/each}

{#each users as user (user.id)}
  <li>{user.name}</li>
{/each}
```

### 🧹 Auto Cleanup

Delete a `.ghtml` file and we clean up the generated `.gleam` file automatically. No orphans left behind.

<p align="center">
  <img src="https://raw.githubusercontent.com/burakcorekci/ghtml/master/assets/gifs/cleanup.gif" alt="Auto cleanup demo" width="90%" />
</p>

Outside of watch mode, you can manually remove orphaned files:

```sh
gleam run -m ghtml -- clean
```

### 🎨 Events

Event handlers? We got 'em.

```html
<button @click={on_save}>Save</button>
<input @input={handle_input} />
```

### 🔧 Custom Elements

Web components work too. Tags with hyphens automatically use `element()`.

```html
<my-component data={value}>
  <slot-content />
</my-component>
```

---

## Template Syntax

<p align="center">
  <img src="https://raw.githubusercontent.com/burakcorekci/ghtml/master/assets/gifs/syntax.gif" alt="Control flow syntax demo" width="90%" />
</p>

<details>
<summary><strong>📦 Imports & Parameters</strong></summary>

```html
@import(gleam/int)
@import(app/models.{type User})

@params(
  user: User,
  count: Int,
  on_click: fn() -> msg,
)
```

</details>

<details>
<summary><strong>✨ Interpolation</strong></summary>

```html
<!-- Expressions -->
<p>{user.name}</p>
<p>{int.to_string(count)} items</p>

<!-- Literal braces -->
<p>Use {{ and }} for literal braces</p>
```

`{expr}` always inserts text (`expr` must be a `String`).

Whitespace works like JSX: a space between elements on the same line is kept (`<b>a</b> <i>b</i>`), and whitespace that contains a newline is removed. Inside `<pre>` and `<textarea>`, text is kept exactly. `<style>` and `<script>` content is raw text (no `{...}`). `<title>`, `<option>` and `<textarea>` can only contain text and `{expr}`, because Lustre takes their content as a `String`. Character references such as `&amp;`, `&copy;` and `&#169;` are decoded (Lustre escapes the text again when it renders).

</details>

<details>
<summary><strong>🧩 Composition</strong></summary>

Insert other elements (another template, a `children` parameter, `element.map(...)`):

```html
@params(title: String, sidebar: Element(msg), children: List(Element(msg)))

<div class="layout">
  <!-- A single Element(msg) -->
  <aside>{@element sidebar}</aside>
  <main>
    <h1>{title}</h1>
    <!-- A List(Element(msg)) -->
    {@elements children}
  </main>
</div>
```

`{@element expr}` inserts `expr` as is. `{@elements expr}` inserts `fragment(expr)`.

**Pass markup to another template** with a call block. The content becomes a `List(Element(msg))` argument, named `children` by default, or the name after `as`:

```html
@import(components/layout)
@import(components/card)

{#call layout.render(title: "Users")}
  {#call card.render(title: "List") as body}
    <ul>
      {#each users as user (user.id)}
        <li>{user.name}</li>
      {/each}
    </ul>
  {/call}
{/call}
```

This generates `layout.render(title: "Users", children: [card.render(title: "List", body: [...])])`. Generated `render` functions have labelled parameters, so `layout.ghtml` only needs `@params(title: String, children: List(Element(msg)))`. Any function call works, also your own Gleam functions with a matching label.

</details>

<details>
<summary><strong>⚠️ Raw HTML</strong></summary>

`{@html expr}` renders a `String` as HTML, without escaping. It must be the only child of an element:

```html
<article class="post">{@html rendered_markdown}</article>
<svg viewBox="0 0 24 24">{@html icon_paths}</svg>
```

It generates `element.unsafe_raw_html(...)`. Only use it with trusted HTML.

</details>

<details>
<summary><strong>🔀 Control Flow</strong></summary>

```html
<!-- Conditionals -->
{#if show}
  <p>Visible!</p>
{:else}
  <p>Hidden</p>
{/if}

<!-- Loops -->
{#each items as item, index}
  <li>{int.to_string(index)}: {item}</li>
{/each}

<!-- Keyed loops: add a String key in ( ) for lists that change order -->
{#each users as user (user.id)}
  <li>{user.name}</li>
{/each}

<!-- Pattern matching -->
{#case status}
  {:Active}
    <span class="green">Active</span>
  {:Pending}
    <span class="yellow">Pending</span>
{/case}
```

</details>

<details>
<summary><strong>🖼️ SVG</strong></summary>

Elements inside `<svg>` are created in the SVG namespace. Tag and attribute names keep their case:

```html
<svg viewBox="0 0 24 24" width={size} height={size}>
  <defs>
    <linearGradient id="g"><stop offset="0" /></linearGradient>
  </defs>
  {#each points as p (p.id)}
    <circle cx={p.x} cy={p.y} r="2" />
  {/each}
  <foreignObject width="20" height="20">
    <p>HTML again</p>
  </foreignObject>
</svg>
```

A template must start at `<svg>`. To reuse parts of an SVG, pass them as elements with `{@element}`.

</details>

<details>
<summary><strong>🎯 Attributes & Events</strong></summary>

To name Lustre types in `@params`, write `attribute.Attribute(msg)`, or import the type yourself with `@import(lustre/attribute.{type Attribute})`. ghtml does not import a module twice.

```html
<!-- Static attributes -->
<div class="container" id="main">

<!-- Dynamic attributes -->
<input value={model.text} placeholder={hint} />

<!-- Boolean attributes -->
<input disabled required />
<button disabled={is_busy}>Save</button>  <!-- Bool -->

<!-- style, width, height: plain strings -->
<div style="color: red" />
<img width="24" height={size} />

<!-- DOM properties (not attributes): the value is a Json -->
<sl-select .value={json.string(selected)}></sl-select>

<!-- Spread a List(Attribute(msg)), in source order -->
<button class="btn" {...extra_attrs}>Go</button>

<!-- Events -->
<button @click={on_submit}>Submit</button>
<input @input={handle_change} @blur={on_blur} />
```

</details>

---

## Example

**Input:** `src/components/user_card.ghtml`

```html
@import(gleam/int)
@params(name: String, count: Int)

<div class="card">
  <h1>{name}</h1>
  <p>{int.to_string(count)} items</p>
</div>
```

**Output:** `src/components/user_card.gleam`

```gleam
// @generated from user_card.ghtml
// @hash abc123...
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import gleam/int
import lustre/attribute
import lustre/element.{type Element, text}
import lustre/element/html

pub fn render(name: String, count: Int) -> Element(msg) {
  html.div([attribute.class("card")], [
    html.h1([], [text(name)]),
    html.p([], [text(int.to_string(count) <> " items")]),
  ])
}
```

---

## Commands

| Command | What it does |
|---------|--------------|
| `gleam run -m ghtml` | Generate all (skips unchanged) |
| `gleam run -m ghtml -- force` | Force regenerate everything |
| `gleam run -m ghtml -- watch` | Watch mode |
| `gleam run -m ghtml -- clean` | Remove orphans only |

---

## Documentation

- 📖 [**Full Documentation**](https://hexdocs.pm/ghtml/) — API reference and guides
- 🤝 [**Contributing**](CONTRIBUTING.md) — Development setup and guidelines
- 📁 [**Examples**](examples/) — Working example projects

---

## Made for Lustre 💖

This tool is built specifically for the [Lustre](https://github.com/lustre-labs/lustre) ecosystem. If you're building web apps with Gleam, you're in the right place.

---

<p align="center">
  <sub>Built with ☕ and too many brackets by <a href="https://github.com/burakcorekci">@burakcorekci</a></sub>
</p>
