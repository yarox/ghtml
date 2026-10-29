//// SSR HTML Verification Tests
////
//// These tests use Lustre's `element.to_string()` to verify that generated
//// components produce the expected HTML output. Tests import the pre-generated
//// modules and verify their rendered output.

import e2e/lustre/generated/attributes
import e2e/lustre/generated/basic
import e2e/lustre/generated/call_page
import e2e/lustre/generated/composition
import e2e/lustre/generated/control_flow
import e2e/lustre/generated/custom_elements
import e2e/lustre/generated/edge_cases
import e2e/lustre/generated/fragments
import e2e/lustre/generated/loops
import e2e/lustre/generated/properties
import e2e/lustre/generated/raw_html
import e2e/lustre/generated/spread_attributes
import e2e/lustre/generated/svg_icon
import e2e/lustre/generated/typed_attributes
import e2e/lustre/generated/types.{Active, Inactive, User}
import gleam/json
import gleam/string
import gleeunit/should
import lustre/attribute
import lustre/element
import lustre/element/html

// =============================================================================
// Basic Template Tests
// =============================================================================

pub fn basic_renders_greeting_class_test() {
  basic.render("Hello")
  |> element.to_string()
  |> string.contains("<div class=\"greeting\">")
  |> should.be_true()
}

pub fn basic_renders_message_in_paragraph_test() {
  basic.render("World")
  |> element.to_string()
  |> string.contains("<p>World</p>")
  |> should.be_true()
}

pub fn basic_dynamic_message_test() {
  basic.render("Dynamic content here")
  |> element.to_string()
  |> string.contains("Dynamic content here")
  |> should.be_true()
}

pub fn basic_empty_message_test() {
  basic.render("")
  |> element.to_string()
  |> string.contains("<p></p>")
  |> should.be_true()
}

// =============================================================================
// Attributes Template Tests
// =============================================================================

pub fn attributes_renders_form_test() {
  attributes.render("test", True, fn(_) { Nil }, fn() { Nil })
  |> element.to_string()
  |> string.contains("<form class=\"form\"")
  |> should.be_true()
}

pub fn attributes_renders_input_type_test() {
  let html =
    attributes.render("val", False, fn(_) { Nil }, fn() { Nil })
    |> element.to_string()

  html |> string.contains("type=\"text\"") |> should.be_true()
}

pub fn attributes_renders_input_class_test() {
  attributes.render("val", False, fn(_) { Nil }, fn() { Nil })
  |> element.to_string()
  |> string.contains("class=\"input\"")
  |> should.be_true()
}

pub fn attributes_renders_value_test() {
  attributes.render("my-value", False, fn(_) { Nil }, fn() { Nil })
  |> element.to_string()
  |> string.contains("value=\"my-value\"")
  |> should.be_true()
}

pub fn attributes_renders_submit_button_test() {
  let html =
    attributes.render("val", False, fn(_) { Nil }, fn() { Nil })
    |> element.to_string()

  html |> string.contains("<button") |> should.be_true()
  html |> string.contains("type=\"submit\"") |> should.be_true()
  html |> string.contains("Submit") |> should.be_true()
}

// =============================================================================
// Control Flow Template Tests
// =============================================================================

pub fn control_flow_if_admin_badge_test() {
  let user = User(name: "Admin", email: "admin@test.com", is_admin: True)

  control_flow.render(user, [], Active)
  |> element.to_string()
  |> string.contains(">Admin<")
  |> should.be_true()
}

pub fn control_flow_if_not_admin_badge_test() {
  let user = User(name: "Regular", email: "regular@test.com", is_admin: False)

  control_flow.render(user, [], Active)
  |> element.to_string()
  |> string.contains(">User<")
  |> should.be_true()
}

pub fn control_flow_article_container_test() {
  let user = User(name: "Test", email: "test@test.com", is_admin: False)

  control_flow.render(user, [], Active)
  |> element.to_string()
  |> string.contains("<article class=\"user-card\"")
  |> should.be_true()
}

pub fn control_flow_each_single_item_test() {
  let user = User(name: "Test", email: "test@test.com", is_admin: False)

  let html =
    control_flow.render(user, ["Apple"], Active)
    |> element.to_string()

  html |> string.contains("Apple") |> should.be_true()
  html |> string.contains("<li") |> should.be_true()
}

pub fn control_flow_each_multiple_items_test() {
  let user = User(name: "Test", email: "test@test.com", is_admin: False)

  let html =
    control_flow.render(user, ["Apple", "Banana", "Cherry"], Active)
    |> element.to_string()

  html |> string.contains("Apple") |> should.be_true()
  html |> string.contains("Banana") |> should.be_true()
  html |> string.contains("Cherry") |> should.be_true()
}

pub fn control_flow_each_empty_list_test() {
  let user = User(name: "Test", email: "test@test.com", is_admin: False)

  let html =
    control_flow.render(user, [], Active)
    |> element.to_string()

  // Should still render the ul container
  html |> string.contains("<ul") |> should.be_true()
}

pub fn control_flow_each_with_index_test() {
  let user = User(name: "Test", email: "test@test.com", is_admin: False)

  let html =
    control_flow.render(user, ["First", "Second"], Active)
    |> element.to_string()

  // Items should have index numbers
  html |> string.contains("0") |> should.be_true()
  html |> string.contains("1") |> should.be_true()
  html |> string.contains("First") |> should.be_true()
  html |> string.contains("Second") |> should.be_true()
}

pub fn control_flow_case_active_status_test() {
  let user = User(name: "Test", email: "test@test.com", is_admin: False)

  control_flow.render(user, [], Active)
  |> element.to_string()
  |> string.contains("status active")
  |> should.be_true()
}

pub fn control_flow_case_inactive_status_test() {
  let user = User(name: "Test", email: "test@test.com", is_admin: False)

  control_flow.render(user, [], Inactive)
  |> element.to_string()
  |> string.contains("status inactive")
  |> should.be_true()
}

pub fn control_flow_badge_class_test() {
  let user = User(name: "Test", email: "test@test.com", is_admin: True)

  control_flow.render(user, [], Active)
  |> element.to_string()
  |> string.contains("class=\"badge\"")
  |> should.be_true()
}

// =============================================================================
// Custom Elements Template Tests
// =============================================================================

pub fn custom_elements_renders_hyphenated_tag_test() {
  custom_elements.render("Hello", True)
  |> element.to_string()
  |> string.contains("<my-component")
  |> should.be_true()
}

pub fn custom_elements_closing_tag_test() {
  custom_elements.render("Hello", True)
  |> element.to_string()
  |> string.contains("</my-component>")
  |> should.be_true()
}

pub fn custom_elements_class_attribute_test() {
  custom_elements.render("Hello", True)
  |> element.to_string()
  |> string.contains("class=\"custom\"")
  |> should.be_true()
}

pub fn custom_elements_renders_slot_content_test() {
  custom_elements.render("Content", False)
  |> element.to_string()
  |> string.contains("<slot-content>")
  |> should.be_true()
}

pub fn custom_elements_slot_content_closing_test() {
  custom_elements.render("Content", False)
  |> element.to_string()
  |> string.contains("</slot-content>")
  |> should.be_true()
}

pub fn custom_elements_renders_content_text_test() {
  custom_elements.render("My custom content", False)
  |> element.to_string()
  |> string.contains("My custom content")
  |> should.be_true()
}

pub fn custom_elements_status_indicator_when_active_test() {
  custom_elements.render("Test", True)
  |> element.to_string()
  |> string.contains("<status-indicator")
  |> should.be_true()
}

pub fn custom_elements_no_status_indicator_when_inactive_test() {
  let html =
    custom_elements.render("Test", False)
    |> element.to_string()

  // When inactive, status-indicator should not appear
  html |> string.contains("status-indicator") |> should.be_false()
}

pub fn custom_elements_active_attribute_test() {
  // Lustre renders empty-value attributes as boolean attributes (no ="")
  custom_elements.render("Test", True)
  |> element.to_string()
  |> string.contains(" active>")
  |> should.be_true()
}

// =============================================================================
// Fragments Template Tests
// =============================================================================

pub fn fragments_renders_header_test() {
  fragments.render([])
  |> element.to_string()
  |> string.contains("<header")
  |> should.be_true()
}

pub fn fragments_renders_main_test() {
  fragments.render([])
  |> element.to_string()
  |> string.contains("<main")
  |> should.be_true()
}

pub fn fragments_renders_footer_test() {
  fragments.render([])
  |> element.to_string()
  |> string.contains("<footer")
  |> should.be_true()
}

pub fn fragments_header_content_test() {
  fragments.render([])
  |> element.to_string()
  |> string.contains("Header Content")
  |> should.be_true()
}

pub fn fragments_footer_content_test() {
  fragments.render([])
  |> element.to_string()
  |> string.contains("Footer Content")
  |> should.be_true()
}

pub fn fragments_header_class_test() {
  fragments.render([])
  |> element.to_string()
  |> string.contains("class=\"header\"")
  |> should.be_true()
}

pub fn fragments_main_class_test() {
  fragments.render([])
  |> element.to_string()
  |> string.contains("class=\"main\"")
  |> should.be_true()
}

pub fn fragments_footer_class_test() {
  fragments.render([])
  |> element.to_string()
  |> string.contains("class=\"footer\"")
  |> should.be_true()
}

pub fn fragments_renders_items_test() {
  let items = ["First", "Second"]
  let html = fragments.render(items) |> element.to_string()

  html |> string.contains("First") |> should.be_true()
  html |> string.contains("Second") |> should.be_true()
}

pub fn fragments_renders_items_in_paragraphs_test() {
  let items = ["Content"]
  fragments.render(items)
  |> element.to_string()
  |> without_fragment_markers()
  |> string.contains("<main class=\"main\"><p>Content</p></main>")
  |> should.be_true()
}

pub fn fragments_empty_items_test() {
  let html = fragments.render([]) |> element.to_string()

  // Should still render header, main, footer even with no items
  html |> string.contains("<header") |> should.be_true()
  html |> string.contains("<main") |> should.be_true()
  html |> string.contains("<footer") |> should.be_true()
}

// =============================================================================
// Edge Cases Template Tests
// =============================================================================

pub fn edge_cases_renders_void_br_test() {
  edge_cases.render()
  |> element.to_string()
  |> string.contains("<br")
  |> should.be_true()
}

pub fn edge_cases_renders_void_input_test() {
  edge_cases.render()
  |> element.to_string()
  |> string.contains("<input")
  |> should.be_true()
}

pub fn edge_cases_input_type_test() {
  edge_cases.render()
  |> element.to_string()
  |> string.contains("type=\"text\"")
  |> should.be_true()
}

pub fn edge_cases_escaped_braces_test() {
  edge_cases.render()
  |> element.to_string()
  |> string.contains("{escaped braces}")
  |> should.be_true()
}

pub fn edge_cases_container_div_test() {
  edge_cases.render()
  |> element.to_string()
  |> string.contains("<div>")
  |> should.be_true()
}

pub fn edge_cases_span_element_test() {
  edge_cases.render()
  |> element.to_string()
  |> string.contains("<span>")
  |> should.be_true()
}

// =============================================================================
// Composition Tests ({@element} / {@elements})
// =============================================================================

/// Lustre marks fragments with HTML comments when rendering to a string.
fn without_fragment_markers(html: String) -> String {
  html
  |> string.replace("<!-- lustre:fragment -->", "")
  |> string.replace("<!-- /lustre:fragment -->", "")
}

fn render_layout() -> String {
  composition.render("Title", html.nav([], [element.text("menu")]), [
    html.p([], [element.text("one")]),
    html.p([], [element.text("two")]),
  ])
  |> element.to_string()
  |> without_fragment_markers()
}

pub fn composition_renders_single_element_test() {
  render_layout()
  |> string.contains("<aside><nav>menu</nav></aside>")
  |> should.be_true()
}

pub fn composition_renders_element_list_in_order_test() {
  render_layout()
  |> string.contains("<main><h1>Title</h1><p>one</p><p>two</p></main>")
  |> should.be_true()
}

pub fn composition_accepts_labelled_arguments_test() {
  composition.render(
    children: [html.p([], [element.text("body")])],
    title: "Labels",
    sidebar: element.none(),
  )
  |> element.to_string()
  |> without_fragment_markers()
  |> string.contains("<main><h1>Labels</h1><p>body</p></main>")
  |> should.be_true()
}

pub fn composition_renders_empty_element_list_test() {
  composition.render("Empty", element.none(), [])
  |> element.to_string()
  |> without_fragment_markers()
  |> string.contains("<main><h1>Empty</h1></main>")
  |> should.be_true()
}

// =============================================================================
// Loop Tests ({#each} with and without keys)
// =============================================================================

fn render_loops() -> String {
  loops.render([#("a", "Alpha"), #("b", "Beta")], ["x", "y"])
  |> element.to_string()
  |> without_fragment_markers()
}

pub fn loops_keyed_renders_items_with_keys_test() {
  render_loops()
  |> string.contains(
    "<ul class=\"keyed\"><li data-lustre-key=\"a\">Alpha</li><li data-lustre-key=\"b\">Beta</li></ul>",
  )
  |> should.be_true()
}

pub fn loops_unkeyed_list_of_strings_test() {
  render_loops()
  |> string.contains("<ol class=\"plain\"><li>x</li><li>y</li></ol>")
  |> should.be_true()
}

pub fn loops_empty_lists_test() {
  loops.render([], [])
  |> element.to_string()
  |> without_fragment_markers()
  |> string.contains("<ul class=\"keyed\"></ul><ol class=\"plain\"></ol>")
  |> should.be_true()
}

// =============================================================================
// Attribute typing (style, width/height, boolean attributes with values)
// =============================================================================

fn render_typed(busy: Bool) -> String {
  typed_attributes.render("margin: 0", "16", busy)
  |> element.to_string()
}

pub fn typed_static_style_test() {
  render_typed(False)
  |> string.contains("style=\"color: red\"")
  |> should.be_true()
}

pub fn typed_width_and_height_test() {
  let html = render_typed(False)
  should.be_true(string.contains(html, "width=\"24\""))
  should.be_true(string.contains(html, "height=\"16\""))
}

pub fn typed_boolean_with_value_test() {
  render_typed(False)
  |> string.contains("<input disabled")
  |> should.be_true()
}

pub fn typed_dynamic_boolean_test() {
  should.be_true(string.contains(render_typed(True), "<button disabled"))
  should.be_false(string.contains(render_typed(False), "<button disabled"))
}

pub fn typed_dynamic_style_test() {
  render_typed(False)
  |> string.contains("style=\"margin: 0\"")
  |> should.be_true()
}

// =============================================================================
// SVG Tests
// =============================================================================

fn render_icon() -> String {
  svg_icon.render("24", "Hi", ["3", "5"])
  |> element.to_string()
  |> without_fragment_markers()
}

pub fn svg_root_has_svg_namespace_test() {
  render_icon()
  |> string.starts_with("<svg xmlns=\"http://www.w3.org/2000/svg\"")
  |> should.be_true()
}

pub fn svg_keeps_camel_case_names_test() {
  let html = render_icon()
  should.be_true(string.contains(html, "<linearGradient id=\"g\">"))
  should.be_true(string.contains(html, "viewBox=\"0 0 24 24\""))
}

pub fn svg_renders_loop_children_test() {
  render_icon()
  |> string.contains("<circle r=\"3\"></circle><circle r=\"5\"></circle>")
  |> should.be_true()
}

pub fn svg_renders_text_element_test() {
  render_icon()
  |> string.contains("<text x=\"2\" y=\"20\">Hi</text>")
  |> should.be_true()
}

pub fn svg_foreign_object_holds_html_test() {
  render_icon()
  |> string.contains(
    "<p xmlns=\"http://www.w3.org/1999/xhtml\" class=\"note\">hi</p>",
  )
  |> should.be_true()
}

// =============================================================================
// Raw HTML Tests ({@html})
// =============================================================================

fn render_raw() -> String {
  raw_html.render("<p>Hello <em>world</em></p>", "<circle r=\"4\"></circle>")
  |> element.to_string()
  |> without_fragment_markers()
}

pub fn raw_html_is_not_escaped_test() {
  render_raw()
  |> string.contains(
    "<article class=\"post\"><p>Hello <em>world</em></p></article>",
  )
  |> should.be_true()
}

pub fn raw_html_inside_svg_test() {
  render_raw()
  |> string.contains("viewBox=\"0 0 10 10\"><circle r=\"4\"></circle></svg>")
  |> should.be_true()
}

// =============================================================================
// Attribute Spread Tests ({...attrs})
// =============================================================================

pub fn spread_attributes_are_rendered_test() {
  let html =
    spread_attributes.render([
      attribute.id("save"),
      attribute.attribute("aria-label", "Save"),
    ])
    |> element.to_string()
  should.be_true(string.contains(html, "id=\"save\""))
  should.be_true(string.contains(html, "aria-label=\"Save\""))
  should.be_true(string.contains(html, "class=\"btn\""))
  should.be_true(string.contains(html, "type=\"button\""))
}

pub fn spread_empty_list_test() {
  spread_attributes.render([])
  |> element.to_string()
  |> should.equal("<button class=\"btn\" type=\"button\">Go</button>")
}

// =============================================================================
// DOM Property Tests (.name={json})
// =============================================================================

pub fn properties_compile_and_keep_attributes_test() {
  // Properties are set on the DOM node by the client runtime; they are not
  // part of the server-rendered HTML. Attributes still are.
  properties.render(json.array([1, 2, 3], json.int), "Sales")
  |> element.to_string()
  |> should.equal("<my-chart class=\"chart\" label=\"Sales\"></my-chart>")
}

// =============================================================================
// Call Block Tests ({#call ...}...{/call})
// =============================================================================

fn render_call_page(users: List(String)) -> String {
  call_page.render(users)
  |> element.to_string()
  |> without_fragment_markers()
}

pub fn call_passes_content_as_children_test() {
  render_call_page(["ann"])
  |> string.contains("<main><h1>Users</h1><section class=\"card\">")
  |> should.be_true()
}

pub fn call_passes_content_to_named_argument_test() {
  render_call_page(["ann", "bo"])
  |> string.contains(
    "<section class=\"card\"><h2>List</h2><ul><li>ann</li><li>bo</li></ul></section>",
  )
  |> should.be_true()
}

pub fn call_keeps_content_order_test() {
  render_call_page(["ann", "bo"])
  |> string.contains("</section><p class=\"count\">2 users</p></main>")
  |> should.be_true()
}
