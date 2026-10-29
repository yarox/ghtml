// @generated from search_input.ghtml
// @hash f5b9c4cb6cfeee89e628612a3de32db317c58d41b9d76c1c4117dbcdf0e935c6
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

pub fn render(
  query query: String,
  on_change on_change: fn(String) -> msg,
) -> Element(msg) {
  html.div([attribute.class("search")], [
    html.input([
      attribute.type_("search"),
      attribute.class("input"),
      attribute.value(query),
      attribute.placeholder("Search..."),
      event.on_input(on_change),
    ]),
  ])
}
