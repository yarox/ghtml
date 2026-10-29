// @generated from shadow.ghtml
// @hash 2401bb7a6d83e7d63ce70f98e85815df30afdb9d8b65ac554e2f1d0dd563ff3f
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
