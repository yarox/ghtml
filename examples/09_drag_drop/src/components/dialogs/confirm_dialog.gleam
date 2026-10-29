// @generated from confirm_dialog.ghtml
// @hash 9ec76df7bacdfc2194322753743a5da750c036b7d3aca6ee689c45baa71bafff
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import gleam/dynamic/decode
import lustre/attribute
import lustre/element.{type Element, element, text}
import lustre/element/html
import lustre/event

pub fn render(
  is_open is_open: Bool,
  title title: String,
  message message: String,
  confirm_label confirm_label: String,
  on_confirm on_confirm: fn() -> msg,
  on_cancel on_cancel: fn() -> msg,
  on_close_decoder on_close_decoder: decode.Decoder(msg),
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
          html.p([attribute.class("text-gray-600")], [text(message)]),
          html.div(
            [
              attribute.attribute("slot", "footer"),
              attribute.class("flex gap-2 justify-end"),
            ],
            [
              element(
                "sl-button",
                [
                  attribute.attribute("variant", "default"),
                  event.on_click(on_cancel()),
                ],
                [text("Cancel")],
              ),
              element(
                "sl-button",
                [
                  attribute.attribute("variant", "danger"),
                  event.on_click(on_confirm()),
                ],
                [text(confirm_label)],
              ),
            ],
          ),
        ],
      )
    False -> html.span([], [])
  }
}
