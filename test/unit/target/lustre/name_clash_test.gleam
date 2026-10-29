//// Template names (parameters, loop and case variables) must not break the
//// generated code:
//// - a name equal to an imported lustre/element function (text, none,
////   fragment, namespaced, unsafe_raw_html) makes the code call that
////   function through the module: element.text(...)
//// - a name equal to a module the generated code uses (html, attribute,
////   event, keyed, list, element) is a parse error

import ghtml/parser
import ghtml/target/lustre
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
    |> list.find(fn(line) { string.starts_with(line, "import lustre/element") })
  line
}

fn parse_error_message(source: String) -> String {
  let assert Error([error, ..]) = parser.parse(source)
  error.message
}

pub fn param_named_text_uses_qualified_text_test() {
  let code = generate("@params(text: String)\n<p>{text} and more</p>")
  should.be_true(string.contains(
    code,
    "html.p([], [element.text(text), element.text(\" and more\")])",
  ))
  should.be_false(string.contains(element_import(code), "text"))
}

pub fn param_named_none_uses_qualified_none_test() {
  let code = generate("@params(none: Bool)\n<p>{#if none}<b>x</b>{/if}</p>")
  should.be_true(string.contains(code, "False -> element.none()"))
}

pub fn loop_variable_named_fragment_test() {
  let code =
    generate("<ul>{#each parts as fragment}<li>{fragment}</li>{/each}</ul>")
  should.be_true(string.contains(code, "element.fragment(list.map(parts,"))
  should.be_true(string.contains(code, "[text(fragment)]"))
}

pub fn case_pattern_variable_is_a_name_test() {
  let code =
    generate(
      "@params(x: X)\n<div>{#case x}{:Label(text)}<b>{text}</b>{/case}</div>",
    )
  should.be_true(string.contains(code, "element.text(text)"))
}

pub fn no_clash_keeps_unqualified_functions_test() {
  let code = generate("@params(name: String)\n<p>{name}</p>")
  should.be_true(string.contains(code, "html.p([], [text(name)])"))
  should.be_true(string.contains(element_import(code), "text"))
}

pub fn param_named_html_is_error_test() {
  parse_error_message("@params(html: String)\n<div>{@html html}</div>")
  |> string.contains("html")
  |> should.be_true
}

pub fn param_named_list_is_error_test() {
  let message = parse_error_message("@params(list: List(String))\n<p>x</p>")
  should.be_true(string.contains(message, "'list'"))
  should.be_true(string.contains(message, "rename"))
}

pub fn loop_variable_named_event_is_error_test() {
  parse_error_message("{#each events as event}<p>{event}</p>{/each}")
  |> string.contains("'event'")
  |> should.be_true
}

pub fn label_only_name_is_not_a_clash_test() {
  // Field access and labels are not variables
  generate("@params(item: Item)\n<p>{item.list}</p>")
  |> string.contains("text(item.list)")
  |> should.be_true
}
