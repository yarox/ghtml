// @generated from md_button.ghtml
// @hash 9345c72689420ef7864ea1822356ff29b8d560ed0101a2e2c0fb9c55be1333a5
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/element.{type Element, element, text}
import lustre/event

pub fn render(
  label label: String,
  on_click on_click: fn() -> msg,
) -> Element(msg) {
  element("md-filled-button", [event.on_click(on_click())], [text(label)])
}
