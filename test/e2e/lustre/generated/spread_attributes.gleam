// @generated from spread.ghtml
// @hash 7666f41fb70e3f2bf18ae4aacf289ce7f0c466fffea4a802d64721c233259f3a
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import gleam/list
import lustre/attribute.{type Attribute}
import lustre/element.{type Element, text}
import lustre/element/html

pub fn render(extra: List(Attribute(msg))) -> Element(msg) {
  html.button(
    list.flatten([[attribute.class("btn")], extra, [attribute.type_("button")]]),
    [text("Go")],
  )
}
