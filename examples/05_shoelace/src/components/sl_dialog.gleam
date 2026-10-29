// @generated from sl_dialog.ghtml
// @hash 76455db6cdcc91dadd143454276fa3d385594abb3bd940a6d2d3a863e607f9eb
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import gleam/dynamic/decode
import lustre/attribute
import lustre/element.{type Element, element, text}
import lustre/element/html
import lustre/event

pub fn render(
  title title: String,
  is_open is_open: Bool,
  on_close_decoder on_close_decoder: decode.Decoder(msg),
  on_close_click on_close_click: fn() -> msg,
) -> Element(msg) {
  case is_open {
    True ->
      element(
        "sl-dialog",
        [
          attribute.attribute("label", title),
          attribute.attribute("open", ""),
          event.on("sl-hide", on_close_decoder),
        ],
        [
          html.p([], [text("This is a Shoelace dialog component.")]),
          element(
            "sl-button",
            [
              attribute.attribute("slot", "footer"),
              attribute.attribute("variant", "primary"),
              event.on_click(on_close_click()),
            ],
            [text("Close")],
          ),
        ],
      )
    False ->
      element(
        "sl-dialog",
        [
          attribute.attribute("label", title),
          event.on("sl-hide", on_close_decoder),
        ],
        [
          html.p([], [text("This is a Shoelace dialog component.")]),
          element(
            "sl-button",
            [
              attribute.attribute("slot", "footer"),
              attribute.attribute("variant", "primary"),
              event.on_click(on_close_click()),
            ],
            [text("Close")],
          ),
        ],
      )
  }
}
