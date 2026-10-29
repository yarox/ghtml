// @generated from card.ghtml
// @hash d58ce7e40afd2d7435d3eb6636f658d68e65924c727097741afbe2cd4759cf18
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/attribute
import lustre/element.{type Element, text}
import lustre/element/html

pub fn render(
  title title: String,
  body body: String,
  image_url image_url: String,
) -> Element(msg) {
  html.div(
    [attribute.class("max-w-sm rounded-lg overflow-hidden shadow-lg bg-white")],
    [
      html.img([
        attribute.class("w-full h-48 object-cover"),
        attribute.src(image_url),
        attribute.alt(""),
      ]),
      html.div([attribute.class("px-6 py-4")], [
        html.h3([attribute.class("font-bold text-xl mb-2 text-gray-800")], [
          text(title),
        ]),
        html.p([attribute.class("text-gray-600 text-base")], [text(body)]),
      ]),
    ],
  )
}
