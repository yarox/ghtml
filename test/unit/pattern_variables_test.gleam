import ghtml/codegen_utils
import gleeunit/should

pub fn simple_name_test() {
  codegen_utils.pattern_variables("item")
  |> should.equal(["item"])
}

pub fn tuple_pattern_test() {
  codegen_utils.pattern_variables("#(id, name)")
  |> should.equal(["id", "name"])
}

pub fn constructor_pattern_test() {
  codegen_utils.pattern_variables("Member(since)")
  |> should.equal(["since"])
}

pub fn label_is_not_a_variable_test() {
  codegen_utils.pattern_variables("User(name: n, ..)")
  |> should.equal(["n"])
}

pub fn qualified_constructor_is_not_a_variable_test() {
  codegen_utils.pattern_variables("role.Admin(level)")
  |> should.equal(["level"])
}

pub fn string_contents_are_not_variables_test() {
  codegen_utils.pattern_variables("Tag(\"text\", value)")
  |> should.equal(["value"])
}

pub fn discard_is_not_a_variable_test() {
  codegen_utils.pattern_variables("#(_, b)")
  |> should.equal(["b"])
}
