// @generated from md_outlined_button.ghtml
// @hash c5e8ac4840229886d714bc21f94dcba0d67049b7dd9daf85c52348f0e1b9a71e
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/element.{type Element, element, text}
import lustre/event

pub fn render(
  label label: String,
  on_click on_click: fn() -> msg,
) -> Element(msg) {
  element("md-outlined-button", [event.on_click(on_click())], [text(label)])
}
