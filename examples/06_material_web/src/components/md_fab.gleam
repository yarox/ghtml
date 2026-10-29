// @generated from md_fab.ghtml
// @hash 60ac8317cdf84ebc0882d303f085ee3f514fcc8950fe1168f799ebefb845d20f
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/attribute
import lustre/element.{type Element, element, text}
import lustre/event

pub fn render(icon icon: String, on_click on_click: fn() -> msg) -> Element(msg) {
  element("md-fab", [event.on_click(on_click())], [
    element("md-icon", [attribute.attribute("slot", "icon")], [text(icon)]),
  ])
}
