// @generated from web_components.ghtml
// @hash 332b9e753a6c5389bf350e882f63abfecc8e0a19b8eb9299f0847ae704788841
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/attribute
import lustre/element.{type Element, element, none, text}

pub fn render(
  content content: String,
  is_active is_active: Bool,
) -> Element(msg) {
  element("my-component", [attribute.class("custom")], [
    element("slot-content", [], [text(content)]),
    case is_active {
      True ->
        element("status-indicator", [attribute.attribute("active", "")], [])
      False -> none()
    },
  ])
}
