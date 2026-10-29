// @generated from sl_select.ghtml
// @hash a273d9ab72ea1dad42d7fd12ae55b27459da9d5961a23bc0258f5927e18321ec
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import gleam/dynamic/decode
import gleam/list
import lustre/attribute
import lustre/element.{type Element, element, fragment, text}
import lustre/event
import types.{type Option}

pub fn render(
  label label: String,
  options options: List(Option),
  selected selected: String,
  on_change on_change: decode.Decoder(msg),
) -> Element(msg) {
  element(
    "sl-select",
    [
      attribute.attribute("label", label),
      attribute.value(selected),
      event.on("sl-change", on_change),
    ],
    [
      fragment(
        list.map(options, fn(opt) {
          element("sl-option", [attribute.value(opt.value)], [text(opt.label)])
        }),
      ),
    ],
  )
}
