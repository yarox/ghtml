// @generated from icon.ghtml
// @hash 6b3dca74a1127e3414f5ffedcf53eb6602f056116037baabcfa76c763d9b8c73
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import gleam/list
import lustre/attribute
import lustre/element.{type Element, fragment, namespaced, text}
import lustre/element/html

pub fn render(
  size size: String,
  label label: String,
  radii radii: List(String),
) -> Element(msg) {
  html.svg(
    [
      attribute.class("icon"),
      attribute.attribute("viewBox", "0 0 24 24"),
      attribute.attribute("width", size),
      attribute.attribute("height", size),
    ],
    [
      namespaced("http://www.w3.org/2000/svg", "defs", [], [
        namespaced(
          "http://www.w3.org/2000/svg",
          "linearGradient",
          [attribute.id("g")],
          [
            namespaced(
              "http://www.w3.org/2000/svg",
              "stop",
              [attribute.attribute("offset", "0")],
              [],
            ),
          ],
        ),
      ]),
      namespaced(
        "http://www.w3.org/2000/svg",
        "circle",
        [
          attribute.attribute("cx", "12"),
          attribute.attribute("cy", "12"),
          attribute.attribute("r", "10"),
          attribute.attribute("fill", "url(#g)"),
        ],
        [],
      ),
      fragment(
        list.map(radii, fn(r) {
          namespaced(
            "http://www.w3.org/2000/svg",
            "circle",
            [attribute.attribute("r", r)],
            [],
          )
        }),
      ),
      namespaced(
        "http://www.w3.org/2000/svg",
        "text",
        [attribute.attribute("x", "2"), attribute.attribute("y", "20")],
        [text(label)],
      ),
      namespaced(
        "http://www.w3.org/2000/svg",
        "foreignObject",
        [
          attribute.attribute("width", "10"),
          attribute.attribute("height", "10"),
        ],
        [html.p([attribute.class("note")], [text("hi")])],
      ),
    ],
  )
}
