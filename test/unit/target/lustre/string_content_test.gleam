//// Elements whose Lustre function takes a String instead of children:
//// - <style> and <script>: raw text, read exactly (no {expr}, no tags)
//// - <title>, <option>, <textarea>: text and {expr}, joined with <>

import ghtml/lexer
import ghtml/parser
import ghtml/target/lustre
import ghtml/types.{HtmlClose, HtmlOpen, Text}
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

// === <style> and <script> ===

pub fn tokenize_style_content_is_raw_test() {
  let assert Ok([HtmlOpen("style", _, False, _), Text(css, _), HtmlClose(..)]) =
    lexer.tokenize("<style>.a { color: red } a > b {}</style>")
  should.equal(css, ".a { color: red } a > b {}")
}

pub fn tokenize_script_content_is_raw_test() {
  let assert Ok([HtmlOpen("script", _, False, _), Text(js, _), HtmlClose(..)]) =
    lexer.tokenize("<script>if (a < b && c) { go(\"</div>\") }</script>")
  should.equal(js, "if (a < b && c) { go(\"</div>\") }")
}

pub fn tokenize_unclosed_script_is_error_test() {
  lexer.tokenize("<script>let x = 1")
  |> should.be_error
}

pub fn generate_style_test() {
  let code = generate("<style>.a { color: red }</style>")
  should.be_true(string.contains(code, "html.style([], \".a { color: red }\")"))
}

pub fn generate_style_keeps_text_exactly_test() {
  let code = generate("<style>\n  .a &amp; b {}\n</style>")
  should.be_true(string.contains(
    code,
    "html.style([], \"\\n  .a &amp; b {}\\n\")",
  ))
}

pub fn generate_script_with_attributes_test() {
  let code =
    generate("<script type=\"module\">import x from \"./x.js\"</script>")
  should.be_true(string.contains(
    code,
    "html.script([attribute.type_(\"module\")], \"import x from \\\"./x.js\\\"\")",
  ))
}

pub fn generate_empty_script_test() {
  let code = generate("<script src=\"/app.js\"></script>")
  should.be_true(string.contains(
    code,
    "html.script([attribute.src(\"/app.js\")], \"\")",
  ))
}

pub fn generate_style_does_not_import_text_test() {
  let code = generate("<style>p {}</style>")
  should.be_false(string.contains(element_import(code), "text"))
}

// === <title>, <option>, <textarea> ===

pub fn generate_option_with_text_test() {
  let code = generate("<option value=\"a\">Apple</option>")
  should.be_true(string.contains(
    code,
    "html.option([attribute.value(\"a\")], \"Apple\")",
  ))
}

pub fn generate_option_with_expression_test() {
  let code = generate("<option value={id}>{label}</option>")
  should.be_true(string.contains(
    code,
    "html.option([attribute.value(id)], label)",
  ))
}

pub fn generate_title_mixed_text_and_expressions_test() {
  let code = generate("<title>{page} | {site} &amp; more</title>")
  should.be_true(string.contains(
    code,
    "html.title([], page <> \" | \" <> site <> \" & more\")",
  ))
}

pub fn generate_empty_textarea_test() {
  let code = generate("<textarea name=\"note\"></textarea>")
  should.be_true(string.contains(
    code,
    "html.textarea([attribute.name(\"note\")], \"\")",
  ))
}

pub fn generate_textarea_keeps_whitespace_test() {
  let code = generate("<textarea>  a\n  b</textarea>")
  should.be_true(string.contains(code, "html.textarea([], \"  a\\n  b\")"))
}

pub fn generate_option_in_loop_test() {
  let code =
    generate(
      "<select>{#each opts as opt (opt.id)}<option value={opt.id}>{opt.label}</option>{/each}</select>",
    )
  should.be_true(string.contains(
    code,
    "#(opt.id, html.option([attribute.value(opt.id)], opt.label))",
  ))
}

pub fn option_text_only_does_not_import_text_test() {
  let code = generate("<select><option>A</option></select>")
  should.be_false(string.contains(element_import(code), "text"))
}

pub fn option_with_element_child_is_error_test() {
  parse_error_message("<option><b>A</b></option>")
  |> string.contains("<option>")
  |> should.be_true
}

pub fn title_with_control_flow_is_error_test() {
  parse_error_message("<title>{#if x}A{/if}</title>")
  |> string.contains("<title>")
  |> should.be_true
}
