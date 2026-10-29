// @generated from md_list.ghtml
// @hash af72d41b87e14b29b40a553f3d34dc74f7ff2bbc7c6daafe6cc3783c13b080eb
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/element.{type Element, text, element, fragment}
import lustre/element/html
import lustre/attribute
import gleam/list
import types.{type ListItem}

pub fn render(items: List(ListItem)) -> Element(msg) {
  element("md-list", [], [fragment(list.map(items, fn(item) { element("md-list-item", [], [html.span([attribute.attribute("slot", "headline")], [text(item.headline)]), html.span([attribute.attribute("slot", "supporting-text")], [text(item.supporting)])]) }))])
}
