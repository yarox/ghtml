// @generated from demo_all.ghtml
// @hash c686ea3f24a7f957228701dd7e57bd02091973f90cbbd2158d1140196b88fec8
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/element.{type Element, text, none, fragment}
import lustre/element/html
import lustre/attribute
import gleam/list
import gleam/int
import types.{type Item}

pub fn render(items: List(Item), show_count: Bool, status: Result(String, String)) -> Element(msg) {
  html.div([attribute.class("demo")], [case show_count { True -> html.p([], [text("Total: "), text(int.to_string(list.length(items)))]) False -> none() }, html.ul([], [fragment(list.index_map(items, fn(item, i) { html.li([], [text(int.to_string(i + 1)), text(". "), text(item.name)]) }))]), case status { Ok(msg) -> html.span([attribute.class("success")], [text(msg)]) Error(err) -> html.span([attribute.class("error")], [text(err)]) }])
}
