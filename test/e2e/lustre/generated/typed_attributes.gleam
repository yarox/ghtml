// @generated from typed.ghtml
// @hash 6b917c0ebe95a23f71727f0b770c79d8ec3a6f69808a79011444f6910484dcda
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/attribute
import lustre/element.{type Element, text}
import lustre/element/html

pub fn render(css: String, size: String, busy: Bool) -> Element(msg) {
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
