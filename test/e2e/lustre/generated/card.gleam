// @generated from card.ghtml
// @hash e606cda2f6949c38aad5a82982b34f5f383bbffa8d0d960048ae366981e8b2a0
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/attribute
import lustre/element.{type Element, fragment, text}
import lustre/element/html

pub fn render(
  title title: String,
  body body: List(Element(msg)),
) -> Element(msg) {
  html.section([attribute.class("card")], [
    html.h2([], [text(title)]),
    fragment(body),
  ])
}
