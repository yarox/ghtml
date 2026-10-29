// @generated from sl_input.ghtml
// @hash 2776478a529e24fea7bb269ad9b463d449cfea0b46614ec5d046f2275ed74313
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import gleam/dynamic/decode
import lustre/attribute
import lustre/element.{type Element, element}
import lustre/event

pub fn render(
  value value: String,
  label label: String,
  placeholder placeholder: String,
  on_input on_input: decode.Decoder(msg),
) -> Element(msg) {
  element(
    "sl-input",
    [
      attribute.value(value),
      attribute.attribute("label", label),
      attribute.placeholder(placeholder),
      event.on("sl-input", on_input),
    ],
    [],
  )
}
