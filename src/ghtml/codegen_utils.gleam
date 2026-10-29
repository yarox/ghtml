//// Shared code generation utilities.
////
//// This module contains target-agnostic helpers used by all code generation
//// backends. Target-specific code lives in ghtml/target/ modules.

import ghtml/types.{
  type Attribute, type CaseBranch, type Node, BooleanAttribute, CaseNode,
  DynamicAttribute, EachNode, Element, EmbedElements, EmbedNode, EventAttribute,
  ExprNode, Fragment, IfNode, StaticAttribute, TextNode,
}
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string

/// List of HTML void elements that cannot have children
const void_elements = [
  "area", "base", "br", "col", "embed", "hr", "img", "input", "link", "meta",
  "param", "source", "track", "wbr",
]

/// Extract the filename from a full path
pub fn extract_filename(path: String) -> String {
  path
  |> string.split("/")
  |> list.last()
  |> result.unwrap("unknown.ghtml")
}

/// The direct child nodes of a node, across all branches.
fn child_nodes(node: Node) -> List(Node) {
  case node {
    Element(_, _, children, _) -> children
    IfNode(_, then_branch, else_branch, _) ->
      list.append(then_branch, else_branch)
    EachNode(body: body, ..) -> body
    CaseNode(_, branches, _) ->
      list.flat_map(branches, fn(b: CaseBranch) { b.body })
    Fragment(children, _) -> children
    TextNode(_, _) | ExprNode(_, _) | EmbedNode(_, _, _) -> []
  }
}

/// True if `predicate` holds for any node in the tree (depth-first).
pub fn any_node(nodes: List(Node), predicate: fn(Node) -> Bool) -> Bool {
  list.any(nodes, fn(node) {
    predicate(node) || any_node(child_nodes(node), predicate)
  })
}

/// Check if template needs `none` import (if without else, or empty branches)
pub fn template_needs_none(nodes: List(Node)) -> Bool {
  any_node(nodes, fn(node) {
    case node {
      IfNode(_, then_branch, else_branch, _) ->
        else_branch == [] || then_branch == []
      CaseNode(_, branches, _) ->
        list.any(branches, fn(b: CaseBranch) { b.body == [] })
      _ -> False
    }
  })
}

/// Check if template needs `fragment` import (multiple roots or multiple children in branches)
pub fn template_needs_fragment(nodes: List(Node)) -> Bool {
  list.length(nodes) > 1
  || any_node(nodes, fn(node) {
    case node {
      IfNode(_, then_branch, else_branch, _) ->
        list.length(then_branch) > 1 || list.length(else_branch) > 1
      // Unkeyed loops and multi-node bodies are wrapped in fragment()
      EachNode(key: None, ..) -> True
      EachNode(body: body, ..) -> list.length(body) > 1
      CaseNode(_, branches, _) ->
        list.any(branches, fn(b: CaseBranch) { list.length(b.body) > 1 })
      Fragment(_, _) -> True
      EmbedNode(EmbedElements, _, _) -> True
      _ -> False
    }
  })
}

/// Check if user has imported a specific module
pub fn has_user_import(imports: List(String), module: String) -> Bool {
  list.any(imports, fn(imp) {
    string.starts_with(imp, module <> ".")
    || string.starts_with(imp, module <> "{")
    || imp == module
  })
}

/// Check if template needs `text` import
pub fn template_needs_text(nodes: List(Node)) -> Bool {
  any_node(nodes, fn(node) {
    case node {
      TextNode(_, _) | ExprNode(_, _) -> True
      _ -> False
    }
  })
}

/// Check if any nodes have each nodes
pub fn template_has_each(nodes: List(Node)) -> Bool {
  any_node(nodes, fn(node) {
    case node {
      EachNode(..) -> True
      _ -> False
    }
  })
}

/// Check if any each loop has an explicit key (needs `lustre/element/keyed`)
pub fn template_has_keyed_each(nodes: List(Node)) -> Bool {
  any_node(nodes, fn(node) {
    case node {
      EachNode(key: Some(_), ..) -> True
      _ -> False
    }
  })
}

/// Check if any nodes have each nodes with index
pub fn template_has_each_with_index(nodes: List(Node)) -> Bool {
  any_node(nodes, fn(node) {
    case node {
      EachNode(index: Some(_), ..) -> True
      _ -> False
    }
  })
}

/// Check if any Gleam expression in the template refers to `module`
/// (for example `int` in `int.to_string(i)`).
pub fn template_uses_module(nodes: List(Node), module: String) -> Bool {
  any_node(nodes, fn(node) {
    node_expressions(node)
    |> list.any(fn(expr) { mentions_module(expr, module) })
  })
}

/// Check if any Gleam expression in the nodes uses the variable `name`.
pub fn nodes_use_variable(nodes: List(Node), name: String) -> Bool {
  any_node(nodes, fn(node) {
    node_expressions(node)
    |> list.any(fn(expr) { expression_uses_variable(expr, name) })
  })
}

/// True if `name` appears in `expr` as a whole identifier that is not a
/// field or module member (`x` matches `f(x)`, not `x_y`, `y.x` or `"x"`
/// is still matched: string contents are not excluded, which only means an
/// index is kept when in doubt).
pub fn expression_uses_variable(expr: String, name: String) -> Bool {
  case string.split(expr, name) {
    [_] | [] -> False
    [first, ..rest] -> uses_variable_loop(first, rest)
  }
}

fn uses_variable_loop(before: String, rest: List(String)) -> Bool {
  case rest {
    [] -> False
    [after, ..more] -> {
      let starts_ok = case string.last(before) {
        Error(_) -> True
        Ok(char) -> !is_identifier_char(char) && char != "."
      }
      let ends_ok = case string.first(after) {
        Error(_) -> True
        Ok(char) -> !is_identifier_char(char)
      }
      { starts_ok && ends_ok } || uses_variable_loop(after, more)
    }
  }
}

/// The Gleam expressions that belong to a node itself (not its children).
fn node_expressions(node: Node) -> List(String) {
  case node {
    ExprNode(expr, _) -> [expr]
    EmbedNode(_, expr, _) -> [expr]
    IfNode(condition, _, _, _) -> [condition]
    EachNode(collection:, key:, ..) ->
      case key {
        Some(key) -> [collection, key]
        None -> [collection]
      }
    CaseNode(expr, branches, _) -> [
      expr,
      ..list.map(branches, fn(b: CaseBranch) { b.pattern })
    ]
    Element(_, attrs, _, _) ->
      list.filter_map(attrs, fn(attr) {
        case attr {
          DynamicAttribute(_, expr) -> Ok(expr)
          EventAttribute(_, handler, _) -> Ok(handler)
          _ -> Error(Nil)
        }
      })
    TextNode(_, _) | Fragment(_, _) -> []
  }
}

/// True if `expr` contains `module.` not preceded by an identifier character.
fn mentions_module(expr: String, module: String) -> Bool {
  case string.split(expr, module <> ".") {
    [_] -> False
    [first, ..rest] -> {
      // Every piece but the last is followed by an occurrence of `module.`
      list.take([first, ..rest], list.length(rest))
      |> list.any(fn(before) {
        case string.last(before) {
          Error(_) -> True
          Ok(char) -> !is_identifier_char(char)
        }
      })
    }
    [] -> False
  }
}

fn is_identifier_char(char: String) -> Bool {
  string.contains(
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_",
    char,
  )
}

/// Check if any nodes have attributes
pub fn template_has_attrs(nodes: List(Node)) -> Bool {
  any_node(nodes, fn(node) {
    case node {
      Element(_, attrs, _, _) -> has_non_event_attrs(attrs)
      _ -> False
    }
  })
}

/// Check if attrs list contains non-event attributes
fn has_non_event_attrs(attrs: List(Attribute)) -> Bool {
  list.any(attrs, fn(attr) {
    case attr {
      StaticAttribute(_, _) -> True
      DynamicAttribute(_, _) -> True
      BooleanAttribute(_) -> True
      EventAttribute(_, _, _) -> False
    }
  })
}

/// Check if any nodes have event attributes
pub fn template_has_events(nodes: List(Node)) -> Bool {
  any_node(nodes, fn(node) {
    case node {
      Element(_, attrs, _, _) -> has_event_attrs(attrs)
      _ -> False
    }
  })
}

/// Check if attrs list contains event attributes
fn has_event_attrs(attrs: List(Attribute)) -> Bool {
  list.any(attrs, fn(attr) {
    case attr {
      EventAttribute(_, _, _) -> True
      _ -> False
    }
  })
}

/// Check if a tag is a custom element (contains a hyphen)
pub fn is_custom_element(tag: String) -> Bool {
  string.contains(tag, "-")
}

/// Check if any nodes have custom elements
pub fn template_has_custom_elements(nodes: List(Node)) -> Bool {
  any_node(nodes, fn(node) {
    case node {
      Element(tag, _, _, _) -> is_custom_element(tag)
      _ -> False
    }
  })
}

/// Check if any nodes have standard HTML elements (non-custom)
pub fn template_has_html_elements(nodes: List(Node)) -> Bool {
  any_node(nodes, fn(node) {
    case node {
      Element(tag, _, _, _) -> !is_custom_element(tag)
      _ -> False
    }
  })
}

/// Check if a tag is a void element (no children allowed)
pub fn is_void_element(tag: String) -> Bool {
  list.contains(void_elements, tag)
}

/// Escape special characters in a string for Gleam code
pub fn escape_string(s: String) -> String {
  s
  |> string.replace("\\", "\\\\")
  |> string.replace("\"", "\\\"")
  |> string.replace("\n", "\\n")
  |> string.replace("\r", "\\r")
  |> string.replace("\t", "\\t")
}

/// Normalize whitespace by collapsing multiple spaces/tabs to single spaces
/// Newlines are preserved (they will be escaped later)
pub fn normalize_whitespace(text: String) -> String {
  text
  |> string.to_graphemes()
  |> collapse_spaces(False, [])
  |> list.reverse()
  |> string.concat()
}

/// Helper function to collapse consecutive spaces/tabs (not newlines)
fn collapse_spaces(
  chars: List(String),
  saw_space: Bool,
  acc: List(String),
) -> List(String) {
  case chars {
    [] -> acc
    [c, ..rest] -> {
      case c {
        // Spaces and tabs get collapsed
        " " | "\t" ->
          case saw_space {
            True -> collapse_spaces(rest, True, acc)
            False -> collapse_spaces(rest, True, [" ", ..acc])
          }
        // Newlines and carriage returns are preserved (will be escaped later)
        "\n" | "\r" -> collapse_spaces(rest, False, [c, ..acc])
        // Regular characters reset the space tracking
        _ -> collapse_spaces(rest, False, [c, ..acc])
      }
    }
  }
}

/// Check if a string is blank (empty or only whitespace)
pub fn is_blank(text: String) -> Bool {
  string.trim(text) == ""
}
