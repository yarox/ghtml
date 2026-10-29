// @generated from card.ghtml
// @hash cba5b50c8106d38baefd585c1ee0716ed12c3bfda3060a91da9b22bed5debf67
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
