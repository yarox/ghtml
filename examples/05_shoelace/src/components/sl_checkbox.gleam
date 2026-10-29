// @generated from sl_checkbox.ghtml
// @hash d02c5724007471b4ac3433f8c69531f11d50f961b1b77bbae0f76a0dafbbf1df
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import gleam/dynamic/decode
import lustre/attribute
import lustre/element.{type Element, element, text}
import lustre/event

pub fn render(
  label label: String,
  is_checked is_checked: Bool,
  on_change on_change: decode.Decoder(msg),
) -> Element(msg) {
  case is_checked {
    True ->
      element(
        "sl-checkbox",
        [attribute.attribute("checked", ""), event.on("sl-change", on_change)],
        [text(label)],
      )
    False ->
      element("sl-checkbox", [event.on("sl-change", on_change)], [text(label)])
  }
}
