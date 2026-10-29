// @generated from sl_select.ghtml
// @hash 1201ca3991affce68e6cfc76787a1ef6e2f2ea1b442b26e76795cad58fdc0b36
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/element.{type Element, text, element, fragment}
import lustre/attribute
import lustre/event
import gleam/list
import types.{type Option}
import gleam/dynamic/decode

pub fn render(label: String, options: List(Option), selected: String, on_change: decode.Decoder(msg)) -> Element(msg) {
  element("sl-select", [attribute.attribute("label", label), attribute.value(selected), event.on("sl-change", on_change)], [fragment(list.map(options, fn(opt) { element("sl-option", [attribute.value(opt.value)], [text(opt.label)]) }))])
}
