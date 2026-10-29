// @generated from typed.ghtml
// @hash c1bee942350bf4151318f335efa8c39ae8d0a5f82a9bc51df36b020dd2b4d00b
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/attribute
import lustre/element.{type Element, text}
import lustre/element/html

pub fn render(
  css css: String,
  size size: String,
  busy busy: Bool,
) -> Element(msg) {
  html.div(
    [attribute.attribute("style", "color: red"), attribute.class("typed")],
    [
      html.img([
        attribute.src("/a.png"),
        attribute.alt("a"),
        attribute.attribute("width", "24"),
        attribute.attribute("height", size),
      ]),
      html.input([attribute.attribute("disabled", "disabled")]),
      html.button(
        [attribute.disabled(busy), attribute.attribute("style", css)],
        [text("Go")],
      ),
    ],
  )
}
