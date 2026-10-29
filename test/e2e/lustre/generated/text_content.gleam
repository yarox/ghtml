// @generated from content.ghtml
// @hash bcdcd0a5eb212a1332280b9f1537eef9d9d74074de97c4aee623d75265eebf06
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import gleam/list
import lustre/attribute
import lustre/element.{type Element, fragment, text}
import lustre/element/html

pub fn render(name name: String, options options: List(String)) -> Element(msg) {
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
    html.style([], ".legal > b { color: red }"),
    html.select([], [
      fragment(
        list.map(options, fn(opt) {
          html.option([attribute.value(opt)], "Pick " <> opt)
        }),
      ),
    ]),
    html.textarea([], "  keep\n this"),
    html.script([], "if (a < b && c) { go() }"),
  ])
}
