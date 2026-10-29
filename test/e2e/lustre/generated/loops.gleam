// @generated from keyed.ghtml
// @hash f82b9579b903564d370dbe565f8aca99376de55ac1ad6a76d55d29c875fac1d2
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import gleam/list
import lustre/attribute
import lustre/element.{type Element, fragment, text}
import lustre/element/html
import lustre/element/keyed

pub fn render(
  rows rows: List(#(String, String)),
  names names: List(String),
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
