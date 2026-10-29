// @generated from md_textfield.ghtml
// @hash 9cb4398eb8281a509674e4caa45245f3aaa76d121f96bddbb4828758567c042b
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/attribute
import lustre/element.{type Element, element}
import lustre/event

pub fn render(
  value value: String,
  label label: String,
  on_input on_input: fn(String) -> msg,
) -> Element(msg) {
  element(
    "md-outlined-text-field",
    [
      attribute.value(value),
      attribute.attribute("label", label),
      event.on_input(on_input),
    ],
    [],
  )
}
