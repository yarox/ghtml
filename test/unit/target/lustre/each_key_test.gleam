//// Tests for `{#each}` keys: unkeyed by default, `(key)` for keyed loops.

import ghtml/lexer
import ghtml/parser
import ghtml/target/lustre
import ghtml/types.{EachNode, EachStart}
import gleam/list
import gleam/option.{None, Some}
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

// === Lexer ===

pub fn tokenize_each_with_key_test() {
  let assert Ok([EachStart(collection, item, index, key, _)]) =
    lexer.tokenize("{#each users as user (user.id)}")
  should.equal(collection, "users")
  should.equal(item, "user")
  should.equal(index, None)
  should.equal(key, Some("user.id"))
}

pub fn tokenize_each_with_index_and_key_test() {
  let assert Ok([EachStart(_, item, index, key, _)]) =
    lexer.tokenize("{#each users as user, i (int.to_string(user.id))}")
  should.equal(item, "user")
  should.equal(index, Some("i"))
  should.equal(key, Some("int.to_string(user.id)"))
}

pub fn tokenize_each_without_key_test() {
  let assert Ok([EachStart(_, item, index, key, _)]) =
    lexer.tokenize("{#each names as name, i}")
  should.equal(item, "name")
  should.equal(index, Some("i"))
  should.equal(key, None)
}

pub fn tokenize_each_tuple_pattern_is_not_a_key_test() {
  let assert Ok([EachStart(_, item, index, key, _)]) =
    lexer.tokenize("{#each pairs as #(a, b)}")
  should.equal(item, "#(a, b)")
  should.equal(index, None)
  should.equal(key, None)
}

pub fn tokenize_each_tuple_pattern_with_key_test() {
  let assert Ok([EachStart(_, item, index, key, _)]) =
    lexer.tokenize("{#each pairs as #(id, name), i (id)}")
  should.equal(item, "#(id, name)")
  should.equal(index, Some("i"))
  should.equal(key, Some("id"))
}

pub fn tokenize_each_empty_key_is_error_test() {
  lexer.tokenize("{#each users as user ()}")
  |> should.be_error
}

// === Parser ===

pub fn parse_each_key_is_kept_test() {
  let assert Ok(template) =
    parser.parse("{#each users as user (user.id)}<p>{user.name}</p>{/each}")
  let assert [EachNode(key: Some("user.id"), ..)] = template.body
}

// === Codegen ===

pub fn generate_unkeyed_each_uses_fragment_test() {
  let code = generate("<ul>{#each names as name}<li>{name}</li>{/each}</ul>")
  should.be_true(string.contains(
    code,
    "fragment(list.map(names, fn(name) { html.li([], [text(name)]) }))",
  ))
  should.be_false(string.contains(code, "keyed"))
  should.be_false(string.contains(code, ".id"))
}

pub fn generate_unkeyed_each_with_index_test() {
  let code = generate("<ul>{#each names as name, i}<li>{name}</li>{/each}</ul>")
  should.be_true(string.contains(
    code,
    "fragment(list.index_map(names, fn(name, _i) {",
  ))
  should.be_false(string.contains(code, "keyed"))
}

pub fn generate_keyed_each_test() {
  let code =
    generate(
      "<ul>{#each users as user (user.id)}<li>{user.name}</li>{/each}</ul>",
    )
  should.be_true(string.contains(
    code,
    "keyed.fragment(list.map(users, fn(user) { #(user.id, html.li([], [text(user.name)])) }))",
  ))
  should.be_true(has_import(code, "lustre/element/keyed"))
}

pub fn generate_keyed_each_with_index_test() {
  let code =
    generate(
      "<ul>{#each users as user, i (user.id)}<li>{user.name}</li>{/each}</ul>",
    )
  should.be_true(string.contains(
    code,
    "keyed.fragment(list.index_map(users, fn(user, _i) { #(user.id, ",
  ))
}

pub fn generate_unkeyed_each_does_not_import_keyed_test() {
  let code = generate("<ul>{#each names as name}<li>{name}</li>{/each}</ul>")
  should.be_false(has_import(code, "lustre/element/keyed"))
}

pub fn generate_index_without_int_usage_does_not_import_int_test() {
  let code = generate("<ul>{#each names as name, i}<li>{name}</li>{/each}</ul>")
  should.be_false(has_import(code, "gleam/int"))
}

pub fn generate_index_with_int_usage_imports_int_test() {
  let code =
    generate(
      "<ul>{#each names as name, i}<li>{int.to_string(i)}: {name}</li>{/each}</ul>",
    )
  should.be_true(has_import(code, "gleam/int"))
}

pub fn generate_unused_index_gets_underscore_test() {
  let code = generate("<ul>{#each names as name, i}<li>{name}</li>{/each}</ul>")
  should.be_true(string.contains(code, "fn(name, _i) {"))
}

pub fn generate_used_index_keeps_name_test() {
  let code =
    generate(
      "<ul>{#each names as name, i}<li>{int.to_string(i)}</li>{/each}</ul>",
    )
  should.be_true(string.contains(code, "fn(name, i) {"))
}

pub fn generate_index_used_in_attribute_keeps_name_test() {
  let code =
    generate(
      "<ul>{#each names as name, i}<li @click={select(i)}>{name}</li>{/each}</ul>",
    )
  should.be_true(string.contains(code, "fn(name, i) {"))
}

pub fn generate_index_used_only_in_key_keeps_name_test() {
  let code =
    generate(
      "<ul>{#each names as name, i (int.to_string(i))}<li>{name}</li>{/each}</ul>",
    )
  should.be_true(string.contains(code, "fn(name, i) {"))
}

pub fn generate_index_name_inside_other_identifier_is_not_use_test() {
  let code =
    generate("<ul>{#each names as name, i}<li>{item.i_name}</li>{/each}</ul>")
  should.be_true(string.contains(code, "fn(name, _i) {"))
}
