// @generated from form_field.ghtml
// @hash 45ebf5d54213588d774d28227e3620de0f158364cbb412b04b765f2e40ad0253
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/attribute
import lustre/element.{type Element, text}
import lustre/element/html

pub fn render(
  label label: String,
  value value: String,
  hint hint: String,
) -> Element(msg) {
  html.div([attribute.class("field")], [
    html.label([attribute.class("label")], [text(label)]),
    html.input([
      attribute.type_("text"),
      attribute.class("input"),
      attribute.value(value),
      attribute.placeholder(hint),
      attribute.required(True),
    ]),
  ])
}
