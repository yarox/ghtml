// @generated from md_text_button.ghtml
// @hash 35690e341b3bbc3a4d2a34eba03b9699cbc9867d70c8c83d8b976f4c310aea2f
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/element.{type Element, element, text}
import lustre/event

pub fn render(
  label label: String,
  on_click on_click: fn() -> msg,
) -> Element(msg) {
  element("md-text-button", [event.on_click(on_click())], [text(label)])
}
