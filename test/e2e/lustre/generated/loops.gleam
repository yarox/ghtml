// @generated from keyed.ghtml
// @hash cf697959243114b104b1ec5855c13b74c242663968a625b8d767e98ef76b20b4
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import gleam/list
import lustre/attribute
import lustre/element.{type Element, fragment, text}
import lustre/element/html
import lustre/element/keyed

pub fn render(
  rows: List(#(String, String)),
  names: List(String),
) -> Element(msg) {
  fragment([
    html.ul([attribute.class("keyed")], [
      keyed.fragment(
        list.map(rows, fn(row) { #(row.0, html.li([], [text(row.1)])) }),
      ),
    ]),
    html.ol([attribute.class("plain")], [
      fragment(list.map(names, fn(name) { html.li([], [text(name)]) })),
    ]),
  ])
}
