// @generated from content.ghtml
// @hash 29dc5cda2661d26aaa5d70bd1508e777a231ae2852205cf5b76e229482660921
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/element.{type Element, text}
import lustre/element/html

pub fn render(name name: String) -> Element(msg) {
  html.article([], [
    html.p([], [
      text("Hello, "),
      html.b([], [text(name)]),
      text(" "),
      html.i([], [text("and friends")]),
      text("!"),
    ]),
    html.pre([], [text("line 1\n    indented")]),
  ])
}
