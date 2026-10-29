// @generated from basic.ghtml
// @hash d70acdeb4951e811d550efd33b6f43e88d80ff731725525e517fddbf4b0da62b
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/attribute
import lustre/element.{type Element, text}
import lustre/element/html

pub fn render(message message: String) -> Element(msg) {
  html.div([attribute.class("greeting")], [html.p([], [text(message)])])
}
