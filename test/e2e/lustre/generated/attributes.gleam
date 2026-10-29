// @generated from all_attrs.ghtml
// @hash cc5f95a5a1339fdd1dfa5e69de050bacf598729dc15d6943c80dbe9adbb52fae
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/attribute
import lustre/element.{type Element, text}
import lustre/element/html
import lustre/event

pub fn render(
  value value: String,
  is_disabled is_disabled: Bool,
  on_change on_change: fn(String) -> msg,
  on_click on_click: fn() -> msg,
) -> Element(msg) {
  html.form([attribute.class("form")], [
    html.input([
      attribute.type_("text"),
      attribute.class("input"),
      attribute.value(value),
      attribute.disabled(is_disabled),
      event.on_input(on_change),
    ]),
    html.button([attribute.type_("submit"), event.on_click(on_click())], [
      text("Submit"),
    ]),
  ])
}
