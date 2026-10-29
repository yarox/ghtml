// @generated from content.ghtml
// @hash d0fa6e2440353c266c93ce2646c49211d4ee21f39fda998c865714d39f73d1e3
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/attribute
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
    html.p([attribute.class("legal"), attribute.title("Q&A")], [
      text("© 2026 Tom & Jerry"),
    ]),
  ])
}
