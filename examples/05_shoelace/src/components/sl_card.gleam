// @generated from sl_card.ghtml
// @hash 63467225a9502589a3fb0d4dd1572fdb4510fe9855c04e8ada60d0401657a23e
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/attribute
import lustre/element.{type Element, element, text}
import lustre/element/html

pub fn render(
  title title: String,
  body body: String,
  image_src image_src: String,
) -> Element(msg) {
  element("sl-card", [attribute.class("card")], [
    html.img([
      attribute.attribute("slot", "image"),
      attribute.src(image_src),
      attribute.alt(""),
    ]),
    html.strong([], [text(title)]),
    html.p([], [text(body)]),
  ])
}
