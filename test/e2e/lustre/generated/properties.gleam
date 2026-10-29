// @generated from chart.ghtml
// @hash a48ab300f05d082f166eab1f31b905d7f1fadf0f263e8cd1211565dea9bae2c6
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
