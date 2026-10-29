// @generated from navbar.ghtml
// @hash 479b9e57318b86e4b546d1a5a98c5299a0956c291620297e6cd97ddcc50f6d47
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import gleam/list
import lustre/attribute
import lustre/element.{type Element, fragment, text}
import lustre/element/html
import types.{type NavItem}

pub fn render(brand brand: String, items items: List(NavItem)) -> Element(msg) {
  html.nav([attribute.class("bg-gray-800 shadow-lg")], [
    html.div([attribute.class("max-w-7xl mx-auto px-4")], [
      html.div([attribute.class("flex justify-between h-16")], [
        html.div([attribute.class("flex items-center")], [
          html.span([attribute.class("text-white font-bold text-xl")], [
            text(brand),
          ]),
        ]),
        html.div([attribute.class("flex items-center space-x-4")], [
          fragment(
            list.map(items, fn(item) {
              html.a(
                [
                  attribute.href(item.href),
                  attribute.class(
                    "text-gray-300 hover:text-white px-3 py-2 rounded-md text-sm font-medium transition-colors",
                  ),
                ],
                [text(item.label)],
              )
            }),
          ),
        ]),
      ]),
    ]),
  ])
}
