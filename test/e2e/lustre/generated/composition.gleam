// @generated from layout.ghtml
// @hash ee2d25003657452ec2833e6d3c71f2bd5df2278d4fb11075b3747928d3b2ed8d
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
