// @generated from spread.ghtml
// @hash 3d4104b9693fbd4f8e3d167fff59400553c932cdd459fcc9546af1f2c890607c
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import gleam/list
import lustre/attribute.{type Attribute}
import lustre/element.{type Element, text}
import lustre/element/html

pub fn render(extra extra: List(Attribute(msg))) -> Element(msg) {
  html.button(
    list.flatten([[attribute.class("btn")], extra, [attribute.type_("button")]]),
    [text("Go")],
  )
}
