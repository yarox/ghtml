// @generated from multiple_roots.ghtml
// @hash ea7878999385ec89ca8e36e5a98fecc262d3a04a5c34876541be3493e10db627
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
