//// Tests for DOM properties: `.name={json}`.

import ghtml/lexer
import ghtml/parser
import ghtml/target/lustre
import ghtml/types.{HtmlOpen, PropertyAttribute}
import gleam/list
import gleam/string
import gleeunit/should

fn generate(source: String) -> String {
  let assert Ok(template) = parser.parse(source)
  lustre.generate(template, "test.ghtml", "abc123")
}

pub fn tokenize_property_test() {
  let assert Ok([HtmlOpen("sl-select", attrs, _, _), ..]) =
    lexer.tokenize("<sl-select .value={json.string(selected)}></sl-select>")
  should.equal(attrs, [PropertyAttribute("value", "json.string(selected)")])
}

pub fn tokenize_property_with_static_value_is_error_test() {
  let assert Error([error, ..]) = lexer.tokenize("<input .value=\"x\" />")
  should.be_true(string.contains(error.message, ".value={"))
}

pub fn tokenize_property_without_name_is_error_test() {
  lexer.tokenize("<input .={x} />")
  |> should.be_error
}

pub fn generate_property_test() {
  let code = generate("<my-chart .data={points}></my-chart>")
  should.be_true(string.contains(code, "attribute.property(\"data\", points)"))
}

pub fn generate_property_imports_attribute_test() {
  let code = generate("<my-chart .data={points}></my-chart>")
  should.be_true(
    string.split(code, "\n")
    |> list.contains("import lustre/attribute"),
  )
}

pub fn generate_property_does_not_clash_with_event_modifiers_test() {
  let code =
    generate("<input .checked={json.bool(on)} @change.prevent={toggle} />")
  should.be_true(string.contains(
    code,
    "attribute.property(\"checked\", json.bool(on))",
  ))
  should.be_true(string.contains(
    code,
    "event.prevent_default(event.on_change(toggle))",
  ))
}
