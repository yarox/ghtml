// @generated from demo_all.ghtml
// @hash b4256c3880c763783d517c49dc0697455fb778f9869a6d128dc3e2dd3b6c2ec1
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import gleam/int
import gleam/list
import lustre/attribute
import lustre/element.{type Element, fragment, none, text}
import lustre/element/html
import types.{type Item}

pub fn render(
  items items: List(Item),
  show_count show_count: Bool,
  status status: Result(String, String),
) -> Element(msg) {
  html.div([attribute.class("demo")], [
    case show_count {
      True ->
        html.p([], [text("Total: "), text(int.to_string(list.length(items)))])
      False -> none()
    },
    html.ul([], [
      fragment(
        list.index_map(items, fn(item, i) {
          html.li([], [text(int.to_string(i + 1)), text(". "), text(item.name)])
        }),
      ),
    ]),
    case status {
      Ok(msg) -> html.span([attribute.class("success")], [text(msg)])
      Error(err) -> html.span([attribute.class("error")], [text(err)])
    },
  ])
}
