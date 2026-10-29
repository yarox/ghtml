//// Tests for SVG: elements inside `<svg>` are created in the SVG namespace.

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
    |> list.find(fn(line) {
      string.starts_with(line, "import lustre/element.{")
    })
  line
}

pub fn svg_root_uses_html_svg_test() {
  let code = generate("<svg viewBox=\"0 0 24 24\"></svg>")
  should.be_true(string.contains(
    code,
    "html.svg([attribute.attribute(\"viewBox\", \"0 0 24 24\")], [])",
  ))
}

pub fn svg_children_use_svg_namespace_test() {
  let code = generate("<svg><circle cx=\"12\" cy=\"12\" r=\"10\" /></svg>")
  should.be_true(string.contains(
    code,
    "namespaced(\"http://www.w3.org/2000/svg\", \"circle\", [",
  ))
  should.be_false(string.contains(code, "html.circle"))
}

pub fn svg_keeps_camel_case_tag_names_test() {
  let code =
    generate(
      "<svg><defs><linearGradient id=\"g\"></linearGradient></defs></svg>",
    )
  should.be_true(string.contains(code, "\"linearGradient\""))
  should.be_true(string.contains(code, "\"defs\""))
}

pub fn svg_nested_children_with_text_test() {
  let code = generate("<svg><g><text x=\"0\">{label}</text></g></svg>")
  should.be_true(string.contains(
    code,
    "namespaced(\"http://www.w3.org/2000/svg\", \"g\", [], [",
  ))
  should.be_true(string.contains(code, "[text(label)]"))
}

pub fn svg_imports_namespaced_test() {
  let code = generate("<svg><path d=\"M0 0\" /></svg>")
  should.be_true(string.contains(element_import(code), "namespaced"))
}

pub fn html_without_svg_does_not_import_namespaced_test() {
  let code = generate("<div><p>Hi</p></div>")
  should.be_false(string.contains(element_import(code), "namespaced"))
}

pub fn svg_without_children_does_not_import_namespaced_test() {
  let code = generate("<svg></svg>")
  should.be_false(string.contains(element_import(code), "namespaced"))
}

pub fn svg_control_flow_children_use_svg_namespace_test() {
  let code =
    generate(
      "<svg>{#each points as p}<circle r={p} />{/each}{#if show}<rect />{/if}</svg>",
    )
  should.be_true(string.contains(code, "\"circle\""))
  should.be_true(string.contains(code, "\"rect\""))
  should.be_false(string.contains(code, "html.circle"))
  should.be_false(string.contains(code, "html.rect"))
}

pub fn svg_foreign_object_switches_back_to_html_test() {
  let code =
    generate(
      "<svg><foreignObject><div class=\"x\">Hi</div></foreignObject></svg>",
    )
  should.be_true(string.contains(code, "\"foreignObject\""))
  should.be_true(string.contains(code, "html.div([attribute.class(\"x\")]"))
}

pub fn svg_boolean_attribute_is_generic_test() {
  let code = generate("<svg><rect hidden /></svg>")
  should.be_true(string.contains(code, "attribute.attribute(\"hidden\", \"\")"))
}

pub fn svg_events_work_on_children_test() {
  let code = generate("<svg><circle @click={on_pick} /></svg>")
  should.be_true(string.contains(code, "event.on_click(on_pick)"))
}

pub fn svg_custom_like_child_does_not_import_element_test() {
  let code = generate("<svg><font-face /></svg>")
  should.be_false(string.contains(element_import(code), " element,"))
  should.be_false(string.contains(element_import(code), " element}"))
}
