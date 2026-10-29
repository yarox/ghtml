// @generated from status_display.ghtml
// @hash 5663cc336e0d45de685eaf0101fc38a1968a1a1f0d1730cc394853ad26698d57
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/attribute
import lustre/element.{type Element, text}
import lustre/element/html
import types.{type Status, Away, Offline, Online}

pub fn render(status status: Status) -> Element(msg) {
  html.div([attribute.class("status-display")], [
    case status {
      Online -> html.span([attribute.class("online")], [text("Online")])
      Away(reason) ->
        html.span([attribute.class("away")], [text("Away: "), text(reason)])
      Offline -> html.span([attribute.class("offline")], [text("Offline")])
    },
  ])
}
