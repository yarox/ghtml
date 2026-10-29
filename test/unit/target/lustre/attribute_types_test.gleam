//// Attributes whose dedicated Lustre function does not take a String.
////
//// `attribute.style` takes two arguments, `attribute.width`/`height` take an
//// Int, and boolean attributes take a Bool. Static values and interpolated
//// Strings must use `attribute.attribute(name, value)` for those.

import ghtml/parser
import ghtml/target/lustre
import gleam/string
import gleeunit/should

fn generate(source: String) -> String {
  let assert Ok(template) = parser.parse(source)
  lustre.generate(template, "test.ghtml", "abc123")
}

pub fn static_style_uses_generic_attribute_test() {
  let code = generate("<div style=\"color: red; margin: 0\"></div>")
  should.be_true(string.contains(
    code,
    "attribute.attribute(\"style\", \"color: red; margin: 0\")",
  ))
  should.be_false(string.contains(code, "attribute.style("))
}

pub fn dynamic_style_uses_generic_attribute_test() {
  let code = generate("<div style={css}></div>")
  should.be_true(string.contains(code, "attribute.attribute(\"style\", css)"))
}

pub fn static_width_and_height_use_generic_attribute_test() {
  let code = generate("<img width=\"24\" height=\"16\" />")
  should.be_true(string.contains(code, "attribute.attribute(\"width\", \"24\")"))
  should.be_true(string.contains(
    code,
    "attribute.attribute(\"height\", \"16\")",
  ))
}

pub fn dynamic_width_is_a_string_test() {
  let code = generate("<img width={w} />")
  should.be_true(string.contains(code, "attribute.attribute(\"width\", w)"))
}

pub fn boolean_attribute_with_static_value_test() {
  let code = generate("<input disabled=\"disabled\" />")
  should.be_true(string.contains(
    code,
    "attribute.attribute(\"disabled\", \"disabled\")",
  ))
}

pub fn boolean_attribute_with_dynamic_bool_test() {
  let code = generate("<input disabled={is_busy} />")
  should.be_true(string.contains(code, "attribute.disabled(is_busy)"))
}

pub fn bare_boolean_attribute_test() {
  let code = generate("<input disabled />")
  should.be_true(string.contains(code, "attribute.disabled(True)"))
}

pub fn string_attribute_keeps_dedicated_function_test() {
  let code = generate("<a href=\"/home\" class={cls}></a>")
  should.be_true(string.contains(code, "attribute.href(\"/home\")"))
  should.be_true(string.contains(code, "attribute.class(cls)"))
}
