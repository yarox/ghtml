//// Tests for element interpolation: `{@element expr}` and `{@elements expr}`.

import ghtml/lexer
import ghtml/parser
import ghtml/target/lustre
import ghtml/types.{Element, Embed, EmbedElement, EmbedElements, EmbedNode}
import gleam/list
import gleam/string
import gleeunit/should

fn generate(source: String) -> String {
  let assert Ok(template) = parser.parse(source)
  lustre.generate(template, "test.ghtml", "abc123")
}

// === Lexer ===

pub fn tokenize_embed_element_test() {
  let assert Ok([Embed(kind, content, _)]) =
    lexer.tokenize("{@element card.render(user)}")
  should.equal(kind, EmbedElement)
  should.equal(content, "card.render(user)")
}

pub fn tokenize_embed_elements_test() {
  let assert Ok([Embed(kind, content, _)]) =
    lexer.tokenize("{@elements children}")
  should.equal(kind, EmbedElements)
  should.equal(content, "children")
}

pub fn tokenize_embed_with_nested_braces_test() {
  let assert Ok([Embed(_, content, _)]) =
    lexer.tokenize("{@element view(Model(..model, open: True))}")
  should.equal(content, "view(Model(..model, open: True))")
}

pub fn tokenize_embed_empty_expression_is_error_test() {
  lexer.tokenize("{@element   }")
  |> should.be_error
}

pub fn tokenize_embed_unknown_directive_is_error_test() {
  lexer.tokenize("{@frobnicate x}")
  |> should.be_error
}

// === Parser ===

pub fn parse_embed_inside_element_test() {
  let assert Ok(template) = parser.parse("<main>{@element content}</main>")
  let assert [Element("main", [], [EmbedNode(EmbedElement, "content", _)], _)] =
    template.body
}

// === Codegen ===

pub fn generate_embed_element_passes_expression_through_test() {
  let code = generate("<main>{@element sidebar.render(model)}</main>")
  should.be_true(string.contains(code, "html.main([], [sidebar.render(model)])"))
  // Not wrapped in text()
  should.be_false(string.contains(code, "text(sidebar"))
}

pub fn generate_embed_elements_uses_fragment_test() {
  let code = generate("<ul>{@elements items}</ul>")
  should.be_true(string.contains(code, "html.ul([], [fragment(items)])"))
  should.be_true(string.contains(code, "fragment"))
}

pub fn generate_embed_elements_imports_fragment_test() {
  let code = generate("<ul>{@elements items}</ul>")
  let assert Ok(import_line) =
    string.split(code, "\n")
    |> list.find(fn(line) {
      string.starts_with(line, "import lustre/element.{")
    })
  should.be_true(string.contains(import_line, "fragment"))
}

pub fn generate_embed_element_does_not_import_text_test() {
  let code = generate("<main>{@element content}</main>")
  let assert Ok(import_line) =
    string.split(code, "\n")
    |> list.find(fn(line) {
      string.starts_with(line, "import lustre/element.{")
    })
  should.be_false(string.contains(import_line, "text"))
}

pub fn generate_embed_element_as_root_test() {
  let code = generate("@params(child: Element(msg))\n{@element child}")
  should.be_true(string.contains(code, "-> Element(msg) {\n  child\n}"))
}

pub fn generate_children_param_pattern_test() {
  let source =
    "@params(title: String, children: List(Element(msg)))

<section class=\"card\">
  <h2>{title}</h2>
  {@elements children}
</section>"
  let code = generate(source)
  should.be_true(string.contains(code, "fragment(children)"))
  should.be_true(string.contains(code, "text(title)"))
}
