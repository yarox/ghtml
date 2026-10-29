import ghtml/entities
import ghtml/parser
import ghtml/target/lustre
import gleam/string
import gleeunit/should

fn generate(source: String) -> String {
  let assert Ok(template) = parser.parse(source)
  lustre.generate(template, "test.ghtml", "abc123")
}

// === entities.decode ===

pub fn decode_named_test() {
  entities.decode("Tom &amp; Jerry &copy; 2026 &lt;b&gt;")
  |> should.equal("Tom & Jerry © 2026 <b>")
}

pub fn decode_numeric_test() {
  entities.decode("&#169; &#xA9; &#XA9;")
  |> should.equal("© © ©")
}

pub fn decode_nbsp_test() {
  entities.decode("a&nbsp;b")
  |> should.equal("a\u{00A0}b")
}

pub fn decode_keeps_unknown_reference_test() {
  entities.decode("&unknownthing; &amp")
  |> should.equal("&unknownthing; &amp")
}

pub fn decode_keeps_plain_ampersand_test() {
  entities.decode("salt & pepper; fish & chips")
  |> should.equal("salt & pepper; fish & chips")
}

pub fn decode_keeps_invalid_numbers_test() {
  entities.decode("&#0; &#xZZ; &#;")
  |> should.equal("&#0; &#xZZ; &#;")
}

// === In templates ===

pub fn text_entities_are_decoded_test() {
  let code = generate("<p>Tom &amp; Jerry &copy;</p>")
  should.be_true(string.contains(code, "text(\"Tom & Jerry ©\")"))
}

pub fn static_attribute_entities_are_decoded_test() {
  let code = generate("<a title=\"Q&amp;A\" href=\"/?a=1&amp;b=2\">x</a>")
  should.be_true(string.contains(code, "attribute.title(\"Q&A\")"))
  should.be_true(string.contains(code, "attribute.href(\"/?a=1&b=2\")"))
}

pub fn nbsp_is_not_removed_as_whitespace_test() {
  let code = generate("<p>&nbsp;</p>")
  should.be_true(string.contains(code, "text(\"\u{00A0}\")"))
}

pub fn pre_entities_are_decoded_test() {
  let code = generate("<pre>a &lt; b</pre>")
  should.be_true(string.contains(code, "text(\"a < b\")"))
}
