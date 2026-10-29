// @generated from layout.ghtml
// @hash 1089f7ed4d0a3e0cb1b311532521368a5caf07df9462aafa4dcb5be5db2298f6
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/attribute
import lustre/element.{type Element, fragment, text}
import lustre/element/html

pub fn render(
  title title: String,
  sidebar sidebar: Element(msg),
  children children: List(Element(msg)),
) -> Element(msg) {
  html.div([attribute.class("layout")], [
    html.aside([], [sidebar]),
    html.main([], [html.h1([], [text(title)]), fragment(children)]),
  ])
}
