// @generated from special.ghtml
// @hash 7950a0186c10e6fe1303605e770c9791ecd96b2c200ee19cd4f4dd87ac9f201d
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/attribute
import lustre/element.{type Element, text}
import lustre/element/html

pub fn render() -> Element(msg) {
  html.div([], [
    html.br([]),
    html.input([attribute.type_("text")]),
    html.span([], [text("Text with {escaped braces}")]),
  ])
}
