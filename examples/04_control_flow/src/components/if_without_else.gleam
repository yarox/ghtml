// @generated from if_without_else.ghtml
// @hash c884c4522bd1fc3f7f1d6dcbe02b91e4d2bed13c1ffb6a7a4f036e068f274bb6
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/attribute
import lustre/element.{type Element, none, text}
import lustre/element/html

pub fn render(
  show_warning show_warning: Bool,
  message message: String,
) -> Element(msg) {
  html.div([attribute.class("notification")], [
    case show_warning {
      True -> html.p([attribute.class("warning")], [text(message)])
      False -> none()
    },
  ])
}
