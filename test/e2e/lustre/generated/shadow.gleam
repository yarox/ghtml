// @generated from shadow.ghtml
// @hash fb42c86fc7d4d59d67ee81e3223a9b4b81c7604cf79c3cafa42cfdcc0a7447c1
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/element.{type Element}
import lustre/element/html

pub fn render(text text: String, none none: Bool) -> Element(msg) {
  html.p([], [
    element.text(text),
    case none {
      True -> html.b([], [element.text("!")])
      False -> element.none()
    },
  ])
}
