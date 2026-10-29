// @generated from alert_success.ghtml
// @hash bbb662347403abdd1223ab8f6a337289945f74157cae3a04b8e3caa8de7fa242
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/attribute
import lustre/element.{type Element, text}
import lustre/element/html

pub fn render(message message: String) -> Element(msg) {
  html.div([attribute.class("rounded-md bg-green-50 p-4 mb-4")], [
    html.div([attribute.class("flex")], [
      html.div([attribute.class("ml-3")], [
        html.p([attribute.class("text-sm font-medium text-green-800")], [
          text(message),
        ]),
      ]),
    ]),
  ])
}
