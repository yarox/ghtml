// @generated from content.ghtml
// @hash 84f38a32ae1bc9f8d2418abc1e1deac8748b7e9660718a33b9447cb0fee83181
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
