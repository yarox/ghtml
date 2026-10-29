// @generated from empty_state.ghtml
// @hash 15c86f5219ae27f7bae9c19a1e2ccf3c4a892a6a6843ae33d957405b3a0f52d2
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/attribute
import lustre/element.{type Element, element, text}
import lustre/element/html
import lustre/event

pub fn render(
  icon icon: String,
  title title: String,
  description description: String,
  action_label action_label: String,
  on_action on_action: fn() -> msg,
) -> Element(msg) {
  html.div(
    [
      attribute.class(
        "flex flex-col items-center justify-center py-12 px-4 text-center",
      ),
    ],
    [
      html.div([attribute.class("text-6xl mb-4")], [text(icon)]),
      html.h3([attribute.class("text-lg font-medium text-gray-900 mb-2")], [
        text(title),
      ]),
      html.p([attribute.class("text-gray-500 mb-6 max-w-sm")], [
        text(description),
      ]),
      element(
        "sl-button",
        [attribute.attribute("variant", "primary"), event.on_click(on_action())],
        [text(action_label)],
      ),
    ],
  )
}
