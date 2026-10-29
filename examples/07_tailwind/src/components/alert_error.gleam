// @generated from alert_error.ghtml
// @hash d2a9bdcb6beddc9b196737cfabd3db3861232d857ae870b30fa95535fe807dfe
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/attribute
import lustre/element.{type Element, text}
import lustre/element/html

pub fn render(message message: String) -> Element(msg) {
  html.div([attribute.class("rounded-md bg-red-50 p-4 mb-4")], [
    html.div([attribute.class("flex")], [
      html.div([attribute.class("ml-3")], [
        html.p([attribute.class("text-sm font-medium text-red-800")], [
          text(message),
        ]),
      ]),
    ]),
  ])
}
