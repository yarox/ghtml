// @generated from md_switch.ghtml
// @hash bb0aa4efc723fab49faabd5d7e3fad00be4c15f83ce378dcb7482d3c5aa0f79c
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/attribute
import lustre/element.{type Element, element}
import lustre/event

pub fn render(
  is_on is_on: Bool,
  on_change on_change: fn() -> msg,
) -> Element(msg) {
  case is_on {
    True ->
      element(
        "md-switch",
        [attribute.attribute("selected", ""), event.on_click(on_change())],
        [],
      )
    False -> element("md-switch", [event.on_click(on_change())], [])
  }
}
