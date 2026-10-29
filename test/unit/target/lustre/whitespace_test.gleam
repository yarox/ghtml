//// Whitespace rules (similar to JSX):
//// - whitespace between siblings on one line becomes one space
//// - whitespace that contains a newline, and whitespace at the start or end
////   of a child list, is removed
//// - inside <pre> and <textarea>, text is kept exactly

import ghtml/parser
import ghtml/target/lustre
import gleam/string
import gleeunit/should

fn generate(source: String) -> String {
  let assert Ok(template) = parser.parse(source)
  lustre.generate(template, "test.ghtml", "abc123")
}

pub fn space_between_inline_elements_is_kept_test() {
  let code = generate("<p><b>Bold</b> <i>it</i></p>")
  should.be_true(string.contains(
    code,
    "html.p([], [html.b([], [text(\"Bold\")]), text(\" \"), html.i([], [text(\"it\")])])",
  ))
}

pub fn space_between_expression_and_element_is_kept_test() {
  let code = generate("<p>{name} <b>!</b></p>")
  should.be_true(string.contains(code, "[text(name), text(\" \"), html.b("))
}

pub fn several_spaces_become_one_test() {
  let code = generate("<p><b>a</b>   <i>b</i></p>")
  should.be_true(string.contains(code, "text(\" \")"))
  should.be_false(string.contains(code, "text(\"   \")"))
}

pub fn whitespace_with_newline_between_elements_is_removed_test() {
  let code = generate("<ul>\n  <li>a</li>\n  <li>b</li>\n</ul>")
  should.be_true(string.contains(
    code,
    "html.ul([], [html.li([], [text(\"a\")]), html.li([], [text(\"b\")])])",
  ))
}

pub fn whitespace_at_edges_is_removed_test() {
  let code = generate("<p> <b>x</b> </p>")
  should.be_true(string.contains(
    code,
    "html.p([], [html.b([], [text(\"x\")])])",
  ))
}

pub fn text_with_newlines_is_collapsed_test() {
  let code = generate("<p>one\n   two</p>")
  should.be_true(string.contains(code, "text(\"one two\")"))
}

pub fn space_inside_control_flow_between_elements_test() {
  let code = generate("<p>{#if x}<b>a</b> <i>b</i>{/if}</p>")
  should.be_true(string.contains(code, "text(\" \")"))
}

pub fn pre_keeps_whitespace_exactly_test() {
  let code = generate("<pre>line 1\n    indented\n\nend</pre>")
  should.be_true(string.contains(
    code,
    "text(\"line 1\\n    indented\\n\\nend\")",
  ))
}

pub fn pre_keeps_whitespace_between_children_test() {
  let code = generate("<pre><code>a</code>\n  <code>b</code></pre>")
  should.be_true(string.contains(code, "text(\"\\n  \")"))
}

pub fn textarea_keeps_whitespace_test() {
  let code = generate("<textarea>  two  spaces\n</textarea>")
  should.be_true(string.contains(code, "text(\"  two  spaces\\n\")"))
}

pub fn whitespace_does_not_break_raw_html_rule_test() {
  parser.parse("<div>\n  {@html body}\n</div>")
  |> should.be_ok
  parser.parse("<div> {@html body} </div>")
  |> should.be_ok
}
