// @generated from chart.ghtml
// @hash 3fdc56e93ac64166a39669488bed81efc1b7d80acc0285df10d3afe8f59ea7ec
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import gleam/json.{type Json}
import lustre/attribute
import lustre/element.{type Element, element}

pub fn render(points points: Json, label label: String) -> Element(msg) {
  element(
    "my-chart",
    [
      attribute.class("chart"),
      attribute.property("data", points),
      attribute.attribute("label", label),
    ],
    [],
  )
}
