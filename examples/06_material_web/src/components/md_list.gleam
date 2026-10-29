// @generated from md_list.ghtml
// @hash d182ba4909f1c864c4a8fefe5b56fe654a9512ae75f5352676214e6d318a7464
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import gleam/list
import lustre/attribute
import lustre/element.{type Element, element, fragment, text}
import lustre/element/html
import types.{type ListItem}

pub fn render(items items: List(ListItem)) -> Element(msg) {
  element("md-list", [], [
    fragment(
      list.map(items, fn(item) {
        element("md-list-item", [], [
          html.span([attribute.attribute("slot", "headline")], [
            text(item.headline),
          ]),
          html.span([attribute.attribute("slot", "supporting-text")], [
            text(item.supporting),
          ]),
        ])
      }),
    ),
  ])
}
