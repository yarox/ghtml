// @generated from checkbox_field.ghtml
// @hash 00e53377505a38f26552224f2782d789919a2a96b4705bb75d7d9edab4c17034
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/attribute
import lustre/element.{type Element, text}
import lustre/element/html

pub fn render(label label: String, is_checked is_checked: Bool) -> Element(msg) {
  html.label([attribute.class("checkbox")], [
    html.input([attribute.type_("checkbox"), attribute.checked(is_checked)]),
    html.span([], [text(label)]),
  ])
}
