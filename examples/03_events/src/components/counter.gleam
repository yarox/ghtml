// @generated from counter.ghtml
// @hash 45a06628e7a51c80a3b000989449eb790982520356500c5866c03917c6f55fb0
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import gleam/int
import lustre/attribute
import lustre/element.{type Element, text}
import lustre/element/html
import lustre/event

pub fn render(
  count count: Int,
  on_increment on_increment: fn() -> msg,
  on_decrement on_decrement: fn() -> msg,
) -> Element(msg) {
  html.div([attribute.class("counter")], [
    html.button([attribute.class("btn"), event.on_click(on_decrement())], [
      text("-"),
    ]),
    html.span([attribute.class("count")], [text(int.to_string(count))]),
    html.button([attribute.class("btn"), event.on_click(on_increment())], [
      text("+"),
    ]),
  ])
}
