// @generated from button_primary.ghtml
// @hash 0f62eedacac435973c8d5ca420f92f6711ee57699c0074ce2983352adaf421ef
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
        "px-4 py-2 rounded-md font-medium bg-blue-600 text-white hover:bg-blue-700 focus:ring-blue-500 transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2",
      ),
      event.on_click(on_click()),
    ],
    [text(label)],
  )
}
