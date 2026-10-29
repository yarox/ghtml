// @generated from greeting.ghtml
// @hash fd725c1991f18da515970d1be61bf729860e13e7119f69849450882db25eb2ee
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/attribute
import lustre/element.{type Element, text}
import lustre/element/html

pub fn render(name name: String) -> Element(msg) {
  html.div([attribute.class("greeting")], [
    html.h1([], [text("Hello, "), text(name), text("!")]),
    html.p([], [text("Welcome to ghtml templates.")]),
  ])
}
