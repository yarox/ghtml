// @generated from link_button.ghtml
// @hash bb0f3f46032e2de4c9208fbca7608e834a3b31895502c1becf95c33b5c3e1d23
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/attribute
import lustre/element.{type Element, text}
import lustre/element/html

pub fn render(
  url url: String,
  label label: String,
  is_external is_external: Bool,
) -> Element(msg) {
  html.a(
    [
      attribute.href(url),
      attribute.class("btn"),
      attribute.target(case is_external {
        True -> "_blank"
        False -> "_self"
      }),
      attribute.rel(case is_external {
        True -> "noopener noreferrer"
        False -> ""
      }),
    ],
    [text(label)],
  )
}
