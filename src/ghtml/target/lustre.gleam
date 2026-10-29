//// Lustre target backend for code generation.
////
//// This module contains the Lustre-specific code generation logic,
//// producing Gleam source that uses the Lustre framework's element types.
//// It uses shared utilities from ghtml/codegen for common operations.

import ghtml/cache
import ghtml/codegen_utils
import ghtml/types.{
  type Attribute, type CaseBranch, type Node, type Template, BooleanAttribute,
  CallNode, CaseNode, DynamicAttribute, EachNode, Element, EmbedElement,
  EmbedElements, EmbedHtml, EmbedNode, EventAttribute, ExprNode, Fragment,
  IfNode, PropertyAttribute, SpreadAttribute, StaticAttribute, TextNode,
}
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string

/// Known HTML attributes that have dedicated Lustre functions.
/// Attributes whose Lustre function does not take a single String
/// (`style`, `width`, `height`) are left out on purpose: they use
/// `attribute.attribute(name, value)`. Boolean attributes are also listed in
/// `boolean_attributes`; their functions take a Bool.
const known_attributes = [
  #("class", "attribute.class"),
  #("id", "attribute.id"),
  #("href", "attribute.href"),
  #("src", "attribute.src"),
  #("alt", "attribute.alt"),
  #("type", "attribute.type_"),
  #("value", "attribute.value"),
  #("name", "attribute.name"),
  #("placeholder", "attribute.placeholder"),
  #("disabled", "attribute.disabled"),
  #("readonly", "attribute.readonly"),
  #("checked", "attribute.checked"),
  #("selected", "attribute.selected"),
  #("autofocus", "attribute.autofocus"),
  #("for", "attribute.for"),
  #("role", "attribute.role"),
  #("title", "attribute.title"),
  #("target", "attribute.target"),
  #("rel", "attribute.rel"),
  #("action", "attribute.action"),
  #("method", "attribute.method"),
  #("required", "attribute.required"),
]

/// Boolean attributes that should use dedicated functions for standard elements
const boolean_attributes = [
  "disabled", "readonly", "checked", "selected", "autofocus", "required",
]

/// Generate Gleam code from a parsed template using the Lustre target
pub fn generate(template: Template, source_path: String, hash: String) -> String {
  let filename = codegen_utils.extract_filename(source_path)
  let header = cache.generate_header(filename, hash)
  let imports = generate_imports(template)
  let body = generate_function(template)

  header <> "\n" <> imports <> "\n\n" <> body <> "\n"
}

/// Generate import statements for the generated module
fn generate_imports(template: Template) -> String {
  // lustre/attribute and lustre/event are imported when generated code uses
  // them, or when the template refers to them (`attribute.Attribute(msg)` in
  // @params, `attribute.id(x)` in a spread). If the user imports a module
  // themselves, it is not imported again (that would be a duplicate import).
  let needs_attrs =
    {
      codegen_utils.template_has_attrs(template.body)
      || template_refers_to(template, "attribute")
    }
    && !codegen_utils.has_user_import(template.imports, "lustre/attribute")
  let needs_events =
    {
      codegen_utils.template_has_events(template.body)
      || template_refers_to(template, "event")
    }
    && !codegen_utils.has_user_import(template.imports, "lustre/event")
  let needs_none = codegen_utils.template_needs_none(template.body)
  let needs_fragment = codegen_utils.template_needs_fragment(template.body)
  let needs_each = codegen_utils.template_has_each(template.body)
  let needs_keyed = codegen_utils.template_has_keyed_each(template.body)
  // Index loops traditionally get gleam/int for free; only import it when
  // the template actually uses it, so the generated module has no warnings.
  let needs_int =
    codegen_utils.template_has_each_with_index(template.body)
    && codegen_utils.template_uses_module(template.body, "int")
  let needs_element =
    uses_element_constructor(template.body, Html, fn(tag) {
      codegen_utils.is_custom_element(tag)
    })
  let needs_html =
    uses_element_constructor(template.body, Html, fn(tag) {
      !codegen_utils.is_custom_element(tag)
    })
  let needs_text = codegen_utils.template_needs_text(template.body)
  let user_imports = template.imports

  // Build element import items list
  let element_items = ["type Element"]
  let element_items = case needs_text {
    True -> list.append(element_items, ["text"])
    False -> element_items
  }
  let element_items = case needs_element {
    True -> list.append(element_items, ["element"])
    False -> element_items
  }
  let element_items = case needs_none {
    True -> list.append(element_items, ["none"])
    False -> element_items
  }
  let element_items = case template_has_svg_children(template.body) {
    True -> list.append(element_items, ["namespaced"])
    False -> element_items
  }
  let element_items = case template_has_raw_html(template.body) {
    True -> list.append(element_items, ["unsafe_raw_html"])
    False -> element_items
  }
  let element_items = case needs_fragment {
    True -> list.append(element_items, ["fragment"])
    False -> element_items
  }

  let element_import =
    "import lustre/element.{" <> string.join(element_items, ", ") <> "}"

  let base_imports = case needs_html {
    True -> element_import <> "\nimport lustre/element/html"
    False -> element_import
  }

  // Add keyed import if needed for keyed each loops
  let base_imports = case needs_keyed {
    True -> base_imports <> "\nimport lustre/element/keyed"
    False -> base_imports
  }

  // Add attribute/event imports
  let imports = case needs_attrs, needs_events {
    True, True ->
      base_imports <> "\nimport lustre/attribute\nimport lustre/event"
    True, False -> base_imports <> "\nimport lustre/attribute"
    False, True -> base_imports <> "\nimport lustre/event"
    False, False -> base_imports
  }

  // Add list import if needed for each or spreads, and not already imported
  let needs_list =
    needs_each || codegen_utils.template_has_spread_with_others(template.body)
  let imports = case
    needs_list && !codegen_utils.has_user_import(user_imports, "gleam/list")
  {
    True -> imports <> "\nimport gleam/list"
    False -> imports
  }

  // Add int import if needed for index and not already imported by user
  let imports = case
    needs_int && !codegen_utils.has_user_import(user_imports, "gleam/int")
  {
    True -> imports <> "\nimport gleam/int"
    False -> imports
  }

  // Add user imports
  let imports = case user_imports {
    [] -> imports
    _ -> {
      let user_import_lines =
        list.map(user_imports, fn(imp) { "import " <> imp })
        |> string.join("\n")
      imports <> "\n" <> user_import_lines
    }
  }

  imports
}

/// Check if code generation will emit an HTML-namespace element whose tag
/// matches `matches` (html.tag(...) for standard tags, element(...) for
/// custom ones). Elements in the SVG namespace and elements whose content is
/// `{@html}` use other functions, so they do not count.
fn uses_element_constructor(
  nodes: List(Node),
  ns: Namespace,
  matches: fn(String) -> Bool,
) -> Bool {
  list.any(nodes, fn(node) {
    case node {
      Element(tag, _, children, _) -> {
        let is_raw = case children {
          [EmbedNode(EmbedHtml, _, _)] -> True
          _ -> False
        }
        let child_ns = case ns, tag {
          Html, "svg" -> Svg
          Svg, "foreignObject" -> Html
          _, _ -> ns
        }
        { ns == Html && !is_raw && matches(tag) }
        || uses_element_constructor(children, child_ns, matches)
      }
      IfNode(_, then_branch, else_branch, _) ->
        uses_element_constructor(then_branch, ns, matches)
        || uses_element_constructor(else_branch, ns, matches)
      EachNode(body: body, ..) | CallNode(body: body, ..) ->
        uses_element_constructor(body, ns, matches)
      CaseNode(_, branches, _) ->
        list.any(branches, fn(b: CaseBranch) {
          uses_element_constructor(b.body, ns, matches)
        })
      Fragment(children, _) -> uses_element_constructor(children, ns, matches)
      TextNode(..) | ExprNode(..) | EmbedNode(..) -> False
    }
  })
}

/// Check if the template's parameter types or expressions refer to `module`
fn template_refers_to(template: Template, module: String) -> Bool {
  list.any(template.params, fn(param) {
    codegen_utils.mentions_module(param.1, module)
  })
  || codegen_utils.template_uses_module(template.body, module)
}

/// Check if the template uses `{@html}`
fn template_has_raw_html(nodes: List(Node)) -> Bool {
  codegen_utils.any_node(nodes, fn(node) {
    case node {
      EmbedNode(EmbedHtml, _, _) -> True
      _ -> False
    }
  })
}

/// Check if any `<svg>` element has element children (they need
/// `namespaced` from lustre/element)
fn template_has_svg_children(nodes: List(Node)) -> Bool {
  codegen_utils.any_node(nodes, fn(node) {
    case node {
      Element("svg", _, children, _) ->
        codegen_utils.any_node(children, fn(child) {
          case child {
            Element(..) -> True
            _ -> False
          }
        })
      _ -> False
    }
  })
}

/// Generate the main render function
fn generate_function(template: Template) -> String {
  let params = generate_params(template.params)
  let ns = Html

  case list.length(template.body) {
    0 -> "pub fn render(" <> params <> ") -> Element(msg) {\n  fragment([])\n}"
    1 -> {
      let body =
        generate_node_inline(
          list.first(template.body)
            |> result.unwrap(TextNode(
              "",
              types.point_span(types.start_position()),
            )),
          ns,
        )
      "pub fn render(" <> params <> ") -> Element(msg) {\n  " <> body <> "\n}"
    }
    _ -> {
      // Multiple roots need fragment with multi-line formatting
      let children =
        template.body
        |> list.filter_map(fn(node) {
          let code = generate_node_inline(node, ns)
          case string.trim(code) {
            "" -> Error(Nil)
            _ -> Ok("    " <> code)
          }
        })
        |> string.join(",\n")
      "pub fn render("
      <> params
      <> ") -> Element(msg) {\n  fragment([\n"
      <> children
      <> ",\n  ])\n}"
    }
  }
}

/// Generate function parameters from template params (single line, no
/// trailing comma). Each parameter is also a label (`title title: String`),
/// so callers can write `card.render(title: "x")`; positional calls still
/// work. Discarded names (`_x`) cannot be labels and stay unlabelled.
fn generate_params(params: List(#(String, String))) -> String {
  params
  |> list.map(fn(p) {
    case string.starts_with(p.0, "_") {
      True -> p.0 <> ": " <> p.1
      False -> p.0 <> " " <> p.0 <> ": " <> p.1
    }
  })
  |> string.join(", ")
}

/// Generate code for a single AST node (inline, no indentation)
fn generate_node_inline(node: Node, ns: Namespace) -> String {
  case node {
    Element(tag, attrs, children, _) ->
      generate_element_inline(tag, attrs, children, ns)
    TextNode(content, _) -> generate_text_inline(content)
    ExprNode(expr, _) -> "text(" <> expr <> ")"
    IfNode(condition, then_branch, else_branch, _) ->
      generate_if_node_inline(condition, then_branch, else_branch, ns)
    EachNode(collection, item, index, key, body, _) ->
      generate_each_node_inline(collection, item, index, key, body, ns)
    CaseNode(expr, branches, _) -> generate_case_node_inline(expr, branches, ns)
    Fragment(children, _) -> generate_fragment_inline(children, ns)
    EmbedNode(EmbedElement, expr, _) -> expr
    EmbedNode(EmbedElements, expr, _) -> "fragment(" <> expr <> ")"
    CallNode(expr, label, body, _) ->
      generate_call_inline(expr, option.unwrap(label, "children"), body, ns)
    // The parser only allows {@html} as the only child of an element, where
    // generate_element_inline handles it. This branch is a safe fallback.
    EmbedNode(EmbedHtml, expr, _) ->
      "unsafe_raw_html(\"\", \"span\", [], " <> expr <> ")"
  }
}

/// The namespace elements are created in. Elements inside `<svg>` are SVG
/// elements (except inside `<foreignObject>`, which holds HTML again).
type Namespace {
  Html
  Svg
}

const svg_namespace = "http://www.w3.org/2000/svg"

/// Generate code for an element (inline format)
fn generate_element_inline(
  tag: String,
  attrs: List(Attribute),
  children: List(Node),
  ns: Namespace,
) -> String {
  case children, ns {
    // {@html expr}: the element's content is raw HTML
    [EmbedNode(EmbedHtml, expr, _)], _ -> {
      let #(namespace, is_generic) = case ns, tag {
        Svg, _ | Html, "svg" -> #(svg_namespace, True)
        Html, _ -> #("", codegen_utils.is_custom_element(tag))
      }
      "unsafe_raw_html(\""
      <> namespace
      <> "\", \""
      <> tag
      <> "\", "
      <> generate_attrs(attrs, is_generic)
      <> ", "
      <> expr
      <> ")"
    }
    _, Svg -> {
      // Lustre's svg module has fixed arities and snake_case names, so the
      // generic namespaced() keeps tag names (linearGradient) and children.
      let children_ns = case tag {
        "foreignObject" -> Html
        _ -> Svg
      }
      "namespaced(\""
      <> svg_namespace
      <> "\", \""
      <> tag
      <> "\", "
      <> generate_attrs(attrs, True)
      <> ", ["
      <> generate_children_inline(children, children_ns)
      <> "])"
    }
    _, Html -> generate_html_element(tag, attrs, children)
  }
}

/// Generate code for an element in the HTML namespace
fn generate_html_element(
  tag: String,
  attrs: List(Attribute),
  children: List(Node),
) -> String {
  let is_custom = codegen_utils.is_custom_element(tag)
  let is_void = codegen_utils.is_void_element(tag)
  let attrs_code = generate_attrs(attrs, is_custom)
  // Children of <svg> are SVG elements
  let children_ns = case tag {
    "svg" -> Svg
    _ -> Html
  }

  case is_custom {
    True -> {
      let children_code = generate_children_inline(children, children_ns)
      "element(\""
      <> tag
      <> "\", "
      <> attrs_code
      <> ", ["
      <> children_code
      <> "])"
    }
    False -> {
      case is_void {
        // Void elements in Lustre v5 take only 1 argument (attributes)
        True -> "html." <> tag <> "(" <> attrs_code <> ")"
        False -> {
          let children_code = generate_children_inline(children, children_ns)
          "html." <> tag <> "(" <> attrs_code <> ", [" <> children_code <> "])"
        }
      }
    }
  }
}

/// Generate code for a list of attributes. Spread attributes (`{...xs}`)
/// are joined with the others in source order using `list.flatten`.
fn generate_attrs(attrs: List(Attribute), is_custom: Bool) -> String {
  let segments =
    list.fold(attrs, [], fn(segments, attr) {
      case attr, segments {
        SpreadAttribute(expr), _ -> [Spread(expr), ..segments]
        _, [Plain(codes), ..rest] -> [
          Plain([generate_attr(attr, is_custom), ..codes]),
          ..rest
        ]
        _, _ -> [Plain([generate_attr(attr, is_custom)]), ..segments]
      }
    })
    |> list.reverse
    |> list.map(fn(segment) {
      case segment {
        Spread(expr) -> expr
        Plain(codes) -> "[" <> string.join(list.reverse(codes), ", ") <> "]"
      }
    })

  case segments {
    [] -> "[]"
    [single] -> single
    _ -> "list.flatten([" <> string.join(segments, ", ") <> "])"
  }
}

/// A run of attributes: generated attribute codes (in reverse order) or a
/// spread expression
type AttrSegment {
  Plain(List(String))
  Spread(String)
}

/// Generate code for a single attribute
fn generate_attr(attr: Attribute, is_custom: Bool) -> String {
  case attr {
    StaticAttribute(name, value) -> generate_static_attr(name, value)
    DynamicAttribute(name, expr) -> generate_dynamic_attr(name, expr)
    EventAttribute(event, handler, modifiers) ->
      generate_event_attr(event, handler, modifiers)
    BooleanAttribute(name) -> generate_boolean_attr(name, is_custom)
    // Spreads are handled by generate_attrs
    SpreadAttribute(expr) -> expr
    PropertyAttribute(name, expr) ->
      "attribute.property(\"" <> name <> "\", " <> expr <> ")"
  }
}

/// Generate code for a static attribute
fn generate_static_attr(name: String, value: String) -> String {
  // A boolean attribute with a written value: its function takes a Bool
  let lookup = case list.contains(boolean_attributes, name) {
    True -> Error(Nil)
    False -> find_attr_function(name)
  }
  case lookup {
    Ok(func) -> func <> "(\"" <> codegen_utils.escape_string(value) <> "\")"
    Error(_) ->
      "attribute.attribute(\""
      <> name
      <> "\", \""
      <> codegen_utils.escape_string(value)
      <> "\")"
  }
}

/// Generate code for a dynamic attribute
fn generate_dynamic_attr(name: String, expr: String) -> String {
  case find_attr_function(name) {
    Ok(func) -> func <> "(" <> expr <> ")"
    Error(_) -> "attribute.attribute(\"" <> name <> "\", " <> expr <> ")"
  }
}

/// Generate code for a boolean attribute
fn generate_boolean_attr(name: String, is_custom: Bool) -> String {
  case is_custom {
    True -> "attribute.attribute(\"" <> name <> "\", \"\")"
    False -> {
      case list.contains(boolean_attributes, name) {
        True -> {
          case find_attr_function(name) {
            Ok(func) -> func <> "(True)"
            Error(_) -> "attribute.attribute(\"" <> name <> "\", \"\")"
          }
        }
        False -> "attribute.attribute(\"" <> name <> "\", \"\")"
      }
    }
  }
}

/// Generate code for an event handler attribute
fn generate_event_attr(
  event: String,
  handler: String,
  modifiers: List(String),
) -> String {
  let base = case event {
    "click" -> "event.on_click(" <> handler <> ")"
    "input" -> "event.on_input(" <> handler <> ")"
    "change" -> "event.on_change(" <> handler <> ")"
    "submit" -> "event.on_submit(" <> handler <> ")"
    "blur" -> "event.on_blur(" <> handler <> ")"
    "focus" -> "event.on_focus(" <> handler <> ")"
    "keydown" -> "event.on_keydown(" <> handler <> ")"
    "keyup" -> "event.on_keyup(" <> handler <> ")"
    "keypress" -> "event.on_keypress(" <> handler <> ")"
    "mouseenter" -> "event.on_mouse_enter(" <> handler <> ")"
    "mouseleave" -> "event.on_mouse_leave(" <> handler <> ")"
    "mouseover" -> "event.on_mouse_over(" <> handler <> ")"
    "mouseout" -> "event.on_mouse_out(" <> handler <> ")"
    _ -> {
      // Strip "on:" prefix for custom event handlers (e.g., @on:keydown -> keydown)
      let event_name = case string.starts_with(event, "on:") {
        True -> string.drop_start(event, 3)
        False -> event
      }
      "event.on(\"" <> event_name <> "\", " <> handler <> ")"
    }
  }
  apply_event_modifiers(base, modifiers)
}

/// Apply event modifiers in order, wrapping with appropriate Lustre functions
fn apply_event_modifiers(base: String, modifiers: List(String)) -> String {
  list.fold(modifiers, base, fn(acc, modifier) {
    case modifier {
      "prevent" -> "event.prevent_default(" <> acc <> ")"
      "stop" -> "event.stop_propagation(" <> acc <> ")"
      _ -> acc
    }
  })
}

/// Find the Lustre function for a known attribute
fn find_attr_function(name: String) -> Result(String, Nil) {
  list.find_map(known_attributes, fn(pair) {
    case pair.0 == name {
      True -> Ok(pair.1)
      False -> Error(Nil)
    }
  })
}

/// Generate code for a text node (inline). The parser has already applied
/// the whitespace rules, so the text is used as it is; empty text is skipped.
fn generate_text_inline(content: String) -> String {
  case content {
    "" -> ""
    _ -> "text(\"" <> codegen_utils.escape_string(content) <> "\")"
  }
}

/// Generate code for a list of children nodes (inline, comma-separated)
fn generate_children_inline(children: List(Node), ns: Namespace) -> String {
  children
  |> list.filter_map(fn(child) {
    let code = generate_node_inline(child, ns)
    case string.trim(code) {
      "" -> Error(Nil)
      _ -> Ok(code)
    }
  })
  |> string.join(", ")
}

/// Generate code for an if node (case expression with True/False branches)
fn generate_if_node_inline(
  condition: String,
  then_branch: List(Node),
  else_branch: List(Node),
  ns: Namespace,
) -> String {
  let then_code = generate_branch_content(then_branch, ns)
  let else_code = case else_branch {
    [] -> "none()"
    _ -> generate_branch_content(else_branch, ns)
  }

  "case "
  <> condition
  <> " { True -> "
  <> then_code
  <> " False -> "
  <> else_code
  <> " }"
}

/// Generate code for branch content (single node or fragment for multiple)
fn generate_branch_content(nodes: List(Node), ns: Namespace) -> String {
  case nodes {
    [] -> "none()"
    [single] -> generate_node_inline(single, ns)
    multiple -> {
      let children = generate_children_inline(multiple, ns)
      "fragment([" <> children <> "])"
    }
  }
}

/// Generate code for an each node.
/// Without a key: `fragment(list.map(...))`. With a key:
/// `keyed.fragment(list.map(..., fn(item) { #(key, element) }))`.
fn generate_each_node_inline(
  collection: String,
  item: String,
  index: option.Option(String),
  key: option.Option(String),
  body: List(Node),
  ns: Namespace,
) -> String {
  let body_code = generate_branch_content(body, ns)

  let #(map_function, callback_params) = case index {
    None -> #("list.map", item)
    Some(idx) -> {
      // Prefix an unused index with `_` so the generated code has no warning
      let used =
        codegen_utils.nodes_use_variable(body, idx)
        || case key {
          Some(key) -> codegen_utils.expression_uses_variable(key, idx)
          None -> False
        }
      let idx = case used {
        True -> idx
        False -> "_" <> idx
      }
      #("list.index_map", item <> ", " <> idx)
    }
  }

  let #(wrapper, callback_body) = case key {
    None -> #("fragment", body_code)
    Some(key) -> #("keyed.fragment", "#(" <> key <> ", " <> body_code <> ")")
  }

  wrapper
  <> "("
  <> map_function
  <> "("
  <> collection
  <> ", fn("
  <> callback_params
  <> ") { "
  <> callback_body
  <> " }))"
}

/// Generate code for a call block: the body becomes a list passed to the
/// call as the labelled argument `label`. `f(a)` → `f(a, label: [...])`.
fn generate_call_inline(
  expr: String,
  label: String,
  body: List(Node),
  ns: Namespace,
) -> String {
  let argument = label <> ": [" <> generate_children_inline(body, ns) <> "]"
  case split_last_call(expr) {
    Ok(#(callee, arguments)) ->
      case string.trim(arguments) {
        "" -> callee <> "(" <> argument <> ")"
        arguments -> {
          let arguments = case string.ends_with(arguments, ",") {
            True -> string.drop_end(arguments, 1)
            False -> arguments
          }
          callee <> "(" <> arguments <> ", " <> argument <> ")"
        }
      }
    // The lexer only accepts expressions that end with a call
    Error(_) -> expr <> "(" <> argument <> ")"
  }
}

/// Split `f(a, g(b))` into `#("f", "a, g(b)")`: the text before the `(`
/// that matches the final `)`, and the arguments inside. Parentheses in
/// string literals are ignored.
fn split_last_call(expr: String) -> Result(#(String, String), Nil) {
  let chars = string.to_graphemes(expr)
  let last_index = list.length(chars) - 1
  let open =
    list.index_fold(chars, #([], False, False, Error(Nil)), fn(state, char, i) {
      let #(stack, in_string, escaped, found) = state
      case in_string, escaped, char {
        True, True, _ -> #(stack, True, False, found)
        True, False, "\\" -> #(stack, True, True, found)
        True, False, "\"" -> #(stack, False, False, found)
        True, False, _ -> state
        False, _, "\"" -> #(stack, True, False, found)
        False, _, "(" -> #([i, ..stack], False, False, found)
        False, _, ")" ->
          case stack {
            [open, ..rest] if i == last_index -> #(rest, False, False, Ok(open))
            [_, ..rest] -> #(rest, False, False, found)
            [] -> state
          }
        False, _, _ -> state
      }
    }).3
  case open {
    Ok(open) ->
      Ok(#(
        string.concat(list.take(chars, open)),
        string.concat(
          list.drop(chars, open + 1) |> list.take(last_index - open - 1),
        ),
      ))
    Error(_) -> Error(Nil)
  }
}

/// Generate code for a case node
fn generate_case_node_inline(
  expr: String,
  branches: List(CaseBranch),
  ns: Namespace,
) -> String {
  let branches_code =
    branches
    |> list.map(fn(branch: CaseBranch) {
      let body_code = generate_branch_content(branch.body, ns)
      branch.pattern <> " -> " <> body_code
    })
    |> string.join(" ")

  "case " <> expr <> " { " <> branches_code <> " }"
}

/// Generate code for a fragment node
fn generate_fragment_inline(children: List(Node), ns: Namespace) -> String {
  let children_code = generate_children_inline(children, ns)
  "fragment([" <> children_code <> "])"
}
