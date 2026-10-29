// @generated from sl_button.ghtml
// @hash 67bf35c22862f70654bf78a352cf05c76518a915a9f154512f75271651910ac3
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/attribute
import lustre/element.{type Element, element, text}
import lustre/event

pub fn render(
  label label: String,
  variant variant: String,
  on_click on_click: fn() -> msg,
) -> Element(msg) {
  element(
    "sl-button",
    [attribute.attribute("variant", variant), event.on_click(on_click())],
    [text(label)],
  )
}
