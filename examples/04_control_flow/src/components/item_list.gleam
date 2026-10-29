// @generated from item_list.ghtml
// @hash 7bb02c3d65948c6e417ad8db58ba621c7231c03cec6275583b7b847f28a9a577
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import gleam/int
import gleam/list
import lustre/attribute
import lustre/element.{type Element, fragment, text}
import lustre/element/html
import types.{type Item}

pub fn render(items items: List(Item)) -> Element(msg) {
  html.ul([attribute.class("item-list")], [
    fragment(
      list.index_map(items, fn(item, index) {
        html.li([attribute.class("item")], [
          html.span([attribute.class("index")], [
            text(int.to_string(index)),
            text("."),
          ]),
          html.span([attribute.class("name")], [text(item.name)]),
        ])
      }),
    ),
  ])
}
