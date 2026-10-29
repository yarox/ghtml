// @generated from button_secondary.ghtml
// @hash 6a808666cf434be16ce9ffb50b8c2962a1bf98f9fc2ab5c719418ea09a727b7f
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/attribute
import lustre/element.{type Element, text}
import lustre/element/html
import lustre/event

pub fn render(
  label label: String,
  on_click on_click: fn() -> msg,
) -> Element(msg) {
  html.button(
    [
      attribute.class(
        "px-4 py-2 rounded-md font-medium bg-gray-200 text-gray-800 hover:bg-gray-300 focus:ring-gray-500 transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2",
      ),
      event.on_click(on_click()),
    ],
    [text(label)],
  )
}
