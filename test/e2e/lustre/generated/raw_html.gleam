// @generated from content.ghtml
// @hash b5247a7802136a2e32666e6139d3393a1cc62c5882df3ee5026a291f91fb6345
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/attribute
import lustre/element.{type Element, fragment, unsafe_raw_html}

pub fn render(body body: String, icon icon: String) -> Element(msg) {
  fragment([
    unsafe_raw_html("", "article", [attribute.class("post")], body),
    unsafe_raw_html(
      "http://www.w3.org/2000/svg",
      "svg",
      [attribute.attribute("viewBox", "0 0 10 10")],
      icon,
    ),
  ])
}
