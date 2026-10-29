// @generated from export_dialog.ghtml
// @hash 3325257b7fa7643f7042f554f928d277231e4152ef4b0ef14aabf5a1c403e5e4
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import gleam/dynamic/decode
import lustre/attribute
import lustre/element.{type Element, element, text}
import lustre/element/html
import lustre/event

pub fn render(
  is_open is_open: Bool,
  on_export on_export: fn() -> msg,
  on_import on_import: fn() -> msg,
  on_clear on_clear: fn() -> msg,
  on_close on_close: fn() -> msg,
  on_close_decoder on_close_decoder: decode.Decoder(msg),
) -> Element(msg) {
  case is_open {
    True ->
      element(
        "sl-dialog",
        [
          attribute.attribute("label", "Import / Export"),
          attribute.attribute("open", ""),
          event.on("sl-hide", on_close_decoder),
        ],
        [
          html.div([attribute.class("space-y-4")], [
            html.div([attribute.class("p-4 bg-gray-50 rounded-lg")], [
              html.h3([attribute.class("font-medium text-gray-900 mb-2")], [
                text("Export Tasks"),
              ]),
              html.p([attribute.class("text-sm text-gray-600 mb-3")], [
                text("Download all your tasks as a JSON file."),
              ]),
              element(
                "sl-button",
                [
                  attribute.attribute("variant", "primary"),
                  event.on_click(on_export()),
                ],
                [text("Export to JSON")],
              ),
            ]),
            html.div([attribute.class("p-4 bg-gray-50 rounded-lg")], [
              html.h3([attribute.class("font-medium text-gray-900 mb-2")], [
                text("Import Tasks"),
              ]),
              html.p([attribute.class("text-sm text-gray-600 mb-3")], [
                text("Upload a JSON file to import tasks."),
              ]),
              element(
                "sl-button",
                [
                  attribute.attribute("variant", "default"),
                  event.on_click(on_import()),
                ],
                [text("Import from JSON")],
              ),
            ]),
            html.div([attribute.class("p-4 bg-red-50 rounded-lg")], [
              html.h3([attribute.class("font-medium text-red-900 mb-2")], [
                text("Clear All Data"),
              ]),
              html.p([attribute.class("text-sm text-red-600 mb-3")], [
                text(
                  "Permanently delete all tasks and projects. This action cannot be undone.",
                ),
              ]),
              element(
                "sl-button",
                [
                  attribute.attribute("variant", "danger"),
                  event.on_click(on_clear()),
                ],
                [text("Clear All Data")],
              ),
            ]),
          ]),
          html.div([attribute.attribute("slot", "footer")], [
            element(
              "sl-button",
              [
                attribute.attribute("variant", "default"),
                event.on_click(on_close()),
              ],
              [text("Close")],
            ),
          ]),
        ],
      )
    False -> html.span([], [])
  }
}
