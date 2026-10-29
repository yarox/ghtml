// @generated from md_checkbox.ghtml
// @hash bacd2765ab0cf6c6160199565ee1b753d9b1ddc23b02cac077b92d07e67aa240
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/attribute
import lustre/element.{type Element, element}
import lustre/event

pub fn render(
  is_checked is_checked: Bool,
  on_change on_change: fn() -> msg,
) -> Element(msg) {
  case is_checked {
    True ->
      element(
        "md-checkbox",
        [attribute.attribute("checked", ""), event.on_click(on_change())],
        [],
      )
    False -> element("md-checkbox", [event.on_click(on_change())], [])
  }
}
