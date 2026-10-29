//// Tests for call blocks: `{#call f(args)}...{/call}` passes the content as
//// `children: [...]`; `{#call f(args) as name}` passes it as `name: [...]`.

import ghtml/lexer
import ghtml/parser
import ghtml/target/lustre
import ghtml/types.{CallEnd, CallNode, CallStart, Element}
import gleam/option.{None, Some}
import gleam/string
import gleeunit/should

fn generate(source: String) -> String {
  let assert Ok(template) = parser.parse(source)
  lustre.generate(template, "test.ghtml", "abc123")
}

fn parse_error_message(source: String) -> String {
  let assert Error([error, ..]) = parser.parse(source)
  error.message
}

// === Lexer ===

pub fn tokenize_call_test() {
  let assert Ok([CallStart(expr, label, _), CallEnd(_)]) =
    lexer.tokenize("{#call layout.render(title: \"Home\")}{/call}")
  should.equal(expr, "layout.render(title: \"Home\")")
  should.equal(label, None)
}

pub fn tokenize_call_with_name_test() {
  let assert Ok([CallStart(expr, label, _), CallEnd(_)]) =
    lexer.tokenize("{#call card.render(title: \"x\") as body}{/call}")
  should.equal(expr, "card.render(title: \"x\")")
  should.equal(label, Some("body"))
}

pub fn tokenize_call_keeps_as_inside_arguments_test() {
  let assert Ok([CallStart(expr, label, _), CallEnd(_)]) =
    lexer.tokenize("{#call box.render(text: \"seen as new\")}{/call}")
  should.equal(expr, "box.render(text: \"seen as new\")")
  should.equal(label, None)
}

pub fn tokenize_call_with_braces_in_arguments_test() {
  let assert Ok([CallStart(expr, _, _), CallEnd(_)]) =
    lexer.tokenize("{#call wrap(fn(x) { x })}{/call}")
  should.equal(expr, "wrap(fn(x) { x })")
}

pub fn tokenize_call_without_function_call_is_error_test() {
  let assert Error([error, ..]) = lexer.tokenize("{#call layout}{/call}")
  should.be_true(string.contains(error.message, "{#call"))
}

pub fn tokenize_call_with_invalid_name_is_error_test() {
  lexer.tokenize("{#call f() as Body}{/call}")
  |> should.be_error
}

// === Parser ===

pub fn parse_call_body_test() {
  let assert Ok(template) =
    parser.parse("{#call layout.render(\"Home\")}<p>Hi</p>{/call}")
  let assert [CallNode(expr, None, [Element("p", [], _, _)], _)] = template.body
  should.equal(expr, "layout.render(\"Home\")")
}

pub fn parse_unclosed_call_is_error_test() {
  parse_error_message("{#call f()}<p>Hi</p>")
  |> string.contains("{#call}")
  |> should.be_true
}

pub fn parse_call_end_without_start_is_error_test() {
  parse_error_message("<p>Hi</p>{/call}")
  |> string.contains("{/call}")
  |> should.be_true
}

pub fn parse_raw_html_directly_in_call_is_error_test() {
  parse_error_message("{#call f()}{@html x}{/call}")
  |> string.contains("{@html}")
  |> should.be_true
}

// === Codegen ===

pub fn generate_call_passes_children_test() {
  let code =
    generate(
      "{#call layout.render(title: \"Home\")}<h1>Home</h1><p>{intro}</p>{/call}",
    )
  should.be_true(string.contains(
    code,
    "layout.render(title: \"Home\", children: [html.h1([], [text(\"Home\")]), html.p([], [text(intro)])])",
  ))
}

pub fn generate_call_with_name_test() {
  let code =
    generate("{#call card.render(title: \"x\") as body}<p>Hi</p>{/call}")
  should.be_true(string.contains(
    code,
    "card.render(title: \"x\", body: [html.p([], [text(\"Hi\")])])",
  ))
}

pub fn generate_call_with_no_arguments_test() {
  let code = generate("{#call page.render()}<p>Hi</p>{/call}")
  should.be_true(string.contains(
    code,
    "page.render(children: [html.p([], [text(\"Hi\")])])",
  ))
}

pub fn generate_call_with_trailing_comma_test() {
  let code = generate("{#call page.render(\"a\",)}<p>Hi</p>{/call}")
  should.be_true(string.contains(code, "page.render(\"a\", children: ["))
}

pub fn generate_empty_call_test() {
  let code = generate("{#call page.render(\"a\")}{/call}")
  should.be_true(string.contains(code, "page.render(\"a\", children: [])"))
}

pub fn generate_nested_calls_test() {
  let code =
    generate(
      "{#call layout.render(\"Home\")}{#call card.render(\"Box\") as body}<p>Hi</p>{/call}{/call}",
    )
  should.be_true(string.contains(
    code,
    "layout.render(\"Home\", children: [card.render(\"Box\", body: [html.p([], [text(\"Hi\")])])])",
  ))
}

pub fn generate_call_inside_element_and_loop_test() {
  let code =
    generate(
      "<ul>{#each items as item (item.id)}{#call row.render(item)}<span>{item.name}</span>{/call}{/each}</ul>",
    )
  should.be_true(string.contains(
    code,
    "#(item.id, row.render(item, children: [html.span([], [text(item.name)])]))",
  ))
}

pub fn generate_call_with_control_flow_in_body_test() {
  let code =
    generate(
      "{#call layout.render(\"x\")}{#if show}<p>Yes</p>{/if}{#each names as n}<i>{n}</i>{/each}{/call}",
    )
  should.be_true(string.contains(code, "children: [case show {"))
  should.be_true(string.contains(code, "fragment(list.map(names,"))
}

pub fn generate_call_body_in_svg_keeps_namespace_test() {
  let code = generate("<svg>{#call group.render()}<circle />{/call}</svg>")
  should.be_true(string.contains(
    code,
    "group.render(children: [namespaced(\"http://www.w3.org/2000/svg\", \"circle\", [], [])])",
  ))
}

pub fn generate_call_only_body_text_imports_text_test() {
  let code = generate("{#call layout.render()}Hello{/call}")
  should.be_true(string.contains(code, "children: [text(\"Hello\")]"))
  should.be_true(string.contains(
    code,
    "import lustre/element.{type Element, text}",
  ))
}

pub fn generate_call_with_parenthesis_in_string_argument_test() {
  let code = generate("{#call label.render(\"(a)\", \")\")}<b>x</b>{/call}")
  should.be_true(string.contains(
    code,
    "label.render(\"(a)\", \")\", children: [html.b([], [text(\"x\")])])",
  ))
}

pub fn generate_call_with_as_in_string_and_name_test() {
  let code =
    generate("{#call box.render(\"seen as new\") as body}<b>x</b>{/call}")
  should.be_true(string.contains(
    code,
    "box.render(\"seen as new\", body: [html.b([], [text(\"x\")])])",
  ))
}

pub fn generate_call_on_chained_expression_test() {
  let code = generate("{#call ui.layout(theme).render(\"x\")}<b>y</b>{/call}")
  should.be_true(string.contains(
    code,
    "ui.layout(theme).render(\"x\", children: [",
  ))
}
