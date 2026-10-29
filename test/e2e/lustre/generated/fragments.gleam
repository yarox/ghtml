// @generated from multiple_roots.ghtml
// @hash e05700cc9100828884ea219bc21611797a8ee945a2c8c5804cf52bb7fda7e545
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import gleam/list
import lustre/attribute
import lustre/element.{type Element, fragment, text}
import lustre/element/html

pub fn render(items items: List(String)) -> Element(msg) {
  fragment([
    html.header([attribute.class("header")], [text("Header Content")]),
    html.main([attribute.class("main")], [
      fragment(list.index_map(items, fn(item, _i) { html.p([], [text(item)]) })),
    ]),
    html.footer([attribute.class("footer")], [text("Footer Content")]),
  ])
}
