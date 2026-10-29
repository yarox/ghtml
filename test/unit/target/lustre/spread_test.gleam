//// Tests for attribute spread: `<div {...attrs}>`.

import ghtml/lexer
import ghtml/parser
import ghtml/target/lustre
import ghtml/types.{HtmlOpen, SpreadAttribute, StaticAttribute}
import gleam/list
import gleam/string
import gleeunit/should

fn generate(source: String) -> String {
  let assert Ok(template) = parser.parse(source)
  lustre.generate(template, "test.ghtml", "abc123")
}

fn has_import(code: String, module: String) -> Bool {
  string.split(code, "\n")
  |> list.any(fn(line) { line == "import " <> module })
}

pub fn tokenize_spread_attribute_test() {
  let assert Ok([HtmlOpen("div", attrs, _, _), ..]) =
    lexer.tokenize("<div class=\"a\" {...extra}></div>")
  should.equal(attrs, [StaticAttribute("class", "a"), SpreadAttribute("extra")])
}

pub fn tokenize_spread_with_call_test() {
  let assert Ok([HtmlOpen("div", [SpreadAttribute(expr)], _, _), ..]) =
    lexer.tokenize("<div {...button.attrs(kind: Primary)}></div>")
  should.equal(expr, "button.attrs(kind: Primary)")
}

pub fn tokenize_empty_spread_is_error_test() {
  lexer.tokenize("<div {...}></div>")
  |> should.be_error
}

pub fn generate_only_spread_test() {
  let code = generate("<div {...attrs}></div>")
  should.be_true(string.contains(code, "html.div(attrs, [])"))
  should.be_false(has_import(code, "gleam/list"))
}

pub fn generate_spread_with_other_attributes_keeps_order_test() {
  let code =
    generate("<button class=\"btn\" {...extra} @click={on_click}>Go</button>")
  should.be_true(string.contains(
    code,
    "list.flatten([[attribute.class(\"btn\")], extra, [event.on_click(on_click)]])",
  ))
  should.be_true(has_import(code, "gleam/list"))
}

pub fn generate_two_spreads_test() {
  let code = generate("<div {...a} {...b}></div>")
  should.be_true(string.contains(code, "list.flatten([a, b])"))
}

pub fn generate_spread_on_void_element_test() {
  let code = generate("<input type=\"text\" {...extra} />")
  should.be_true(string.contains(
    code,
    "html.input(list.flatten([[attribute.type_(\"text\")], extra]))",
  ))
}

pub fn generate_spread_does_not_need_attribute_import_test() {
  let code = generate("<div {...attrs}></div>")
  should.be_false(has_import(code, "lustre/attribute"))
}

pub fn generate_attribute_type_in_params_imports_attribute_test() {
  let code =
    generate(
      "@params(extra: List(attribute.Attribute(msg)))\n<div {...extra}></div>",
    )
  should.be_true(has_import(code, "lustre/attribute"))
}

pub fn generate_user_attribute_import_is_not_duplicated_test() {
  let code =
    generate(
      "@import(lustre/attribute.{type Attribute})\n@params(extra: List(Attribute(msg)))\n<div class=\"a\" {...extra}></div>",
    )
  should.be_false(has_import(code, "lustre/attribute"))
  should.be_true(has_import(code, "lustre/attribute.{type Attribute}"))
  should.be_true(string.contains(code, "attribute.class(\"a\")"))
}

pub fn generate_attribute_used_in_spread_expression_test() {
  let code = generate("<div {...[attribute.id(id)]}></div>")
  should.be_true(has_import(code, "lustre/attribute"))
}
