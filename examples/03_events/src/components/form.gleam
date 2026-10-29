// @generated from form.ghtml
// @hash 04d8ab17c2ae3187b9fbbad135456e29f176f5aa96fc0777461b5b70a7d5e074
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/attribute
import lustre/element.{type Element, text}
import lustre/element/html
import lustre/event

pub fn render(
  value value: String,
  on_input on_input: fn(String) -> msg,
  on_click on_click: fn() -> msg,
  on_focus on_focus: fn() -> msg,
  on_blur on_blur: fn() -> msg,
) -> Element(msg) {
  html.div([attribute.class("form")], [
    html.input([
      attribute.type_("text"),
      attribute.class("input"),
      attribute.value(value),
      attribute.placeholder("Type something..."),
      event.on_input(on_input),
      event.on_focus(on_focus()),
      event.on_blur(on_blur()),
    ]),
    html.button([attribute.class("btn"), event.on_click(on_click())], [
      text("Submit"),
    ]),
  ])
}
