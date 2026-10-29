//// Tests for raw HTML: `{@html expr}` as the only child of an element.

import ghtml/lexer
import ghtml/parser
import ghtml/target/lustre
import ghtml/types.{Element, Embed, EmbedHtml, EmbedNode}
import gleam/list
import gleam/string
import gleeunit/should

fn generate(source: String) -> String {
  let assert Ok(template) = parser.parse(source)
  lustre.generate(template, "test.ghtml", "abc123")
}

fn element_import(code: String) -> String {
  let assert Ok(line) =
    string.split(code, "\n")
    |> list.find(fn(line) {
      string.starts_with(line, "import lustre/element.{")
    })
  line
}

fn parse_error_message(source: String) -> String {
  let assert Error([error, ..]) = parser.parse(source)
  error.message
}

// === Lexer and parser ===

pub fn tokenize_html_directive_test() {
  let assert Ok([Embed(kind, content, _)]) = lexer.tokenize("{@html body}")
  should.equal(kind, EmbedHtml)
  should.equal(content, "body")
}

pub fn parse_html_as_only_child_test() {
  let assert Ok(template) = parser.parse("<article>{@html body}</article>")
  let assert [Element("article", _, [EmbedNode(EmbedHtml, "body", _)], _)] =
    template.body
}

pub fn parse_html_with_siblings_is_error_test() {
  parse_error_message("<div><h1>Title</h1>{@html body}</div>")
  |> string.contains("{@html}")
  |> should.be_true
}

pub fn parse_html_with_whitespace_siblings_is_allowed_test() {
  parser.parse("<div>\n  {@html body}\n</div>")
  |> should.be_ok
}

pub fn parse_html_at_root_is_error_test() {
  parse_error_message("{@html body}")
  |> string.contains("{@html}")
  |> should.be_true
}

pub fn parse_html_inside_if_is_error_test() {
  parse_error_message("<div>{#if x}{@html body}{/if}</div>")
  |> string.contains("{@html}")
  |> should.be_true
}

// === Codegen ===

pub fn generate_raw_html_test() {
  let code = generate("<article class=\"post\">{@html body}</article>")
  should.be_true(string.contains(
    code,
    "unsafe_raw_html(\"\", \"article\", [attribute.class(\"post\")], body)",
  ))
  should.be_false(string.contains(code, "html.article"))
}

pub fn generate_raw_html_imports_function_test() {
  let code = generate("<div>{@html body}</div>")
  should.be_true(string.contains(element_import(code), "unsafe_raw_html"))
}

pub fn generate_raw_html_in_svg_uses_svg_namespace_test() {
  let code = generate("<svg viewBox=\"0 0 24 24\">{@html icon}</svg>")
  should.be_true(string.contains(
    code,
    "unsafe_raw_html(\"http://www.w3.org/2000/svg\", \"svg\", [",
  ))
}

pub fn generate_raw_html_in_svg_child_test() {
  let code = generate("<svg><g>{@html paths}</g></svg>")
  should.be_true(string.contains(
    code,
    "unsafe_raw_html(\"http://www.w3.org/2000/svg\", \"g\", [], paths)",
  ))
}

pub fn generate_raw_html_in_custom_element_test() {
  let code = generate("<my-card>{@html body}</my-card>")
  should.be_true(string.contains(
    code,
    "unsafe_raw_html(\"\", \"my-card\", [], body)",
  ))
}

pub fn generate_raw_html_only_does_not_import_html_module_test() {
  let code = generate("<div>{@html body}</div>")
  should.be_false(string.contains(code, "import lustre/element/html"))
}

pub fn generate_raw_html_custom_element_does_not_import_element_test() {
  let code = generate("<my-card>{@html body}</my-card>")
  should.be_false(string.contains(element_import(code), " element"))
}
