// @generated from navbar.ghtml
// @hash 10e0b92c9696fb49577d36ad314b0b27ab9d2814eb3da86b41acaf0cc1fd5b28
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/element.{type Element, text, fragment}
import lustre/element/html
import lustre/attribute
import gleam/list
import types.{type NavItem}

pub fn render(brand: String, items: List(NavItem)) -> Element(msg) {
  html.nav([attribute.class("bg-gray-800 shadow-lg")], [html.div([attribute.class("max-w-7xl mx-auto px-4")], [html.div([attribute.class("flex justify-between h-16")], [html.div([attribute.class("flex items-center")], [html.span([attribute.class("text-white font-bold text-xl")], [text(brand)])]), html.div([attribute.class("flex items-center space-x-4")], [fragment(list.map(items, fn(item) { html.a([attribute.href(item.href), attribute.class("text-gray-300 hover:text-white px-3 py-2 rounded-md text-sm font-medium transition-colors")], [text(item.label)]) }))])])])])
}
