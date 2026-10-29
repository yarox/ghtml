//// Lexer module for `.ghtml` template files.
////
//// Converts template source text into a flat list of tokens for subsequent
//// AST construction by the parser.

import ghtml/types.{
  type Attribute, type EmbedKind, type ParseError, type Position, type Token,
  BooleanAttribute, CallEnd, CallStart, CaseEnd, CasePattern, CaseStart,
  DynamicAttribute, EachEnd, EachStart, Else, Embed, EmbedElement, EmbedElements,
  EmbedHtml, EventAttribute, Expr, HtmlClose, HtmlOpen, IfEnd, IfStart, Import,
  Params, ParseError, Position, PropertyAttribute, Span, SpreadAttribute,
  StaticAttribute, Text,
}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

/// Tokenize a template string into a list of tokens
pub fn tokenize(input: String) -> Result(List(Token), List(ParseError)) {
  let pos = Position(line: 1, column: 1)
  tokenize_loop(input, pos, [])
  |> result.map(fn(tokens) { list.reverse(tokens) })
}

fn tokenize_loop(
  input: String,
  pos: Position,
  tokens: List(Token),
) -> Result(List(Token), List(ParseError)) {
  case input {
    "" -> Ok(tokens)

    // Directive: @import or @params
    "@import" <> rest -> {
      let start_pos = pos
      let pos = advance_pos_str(pos, "@import")
      case parse_import(rest, start_pos, pos) {
        Ok(#(token, remaining, new_pos)) ->
          tokenize_loop(remaining, new_pos, [token, ..tokens])
        Error(err) -> Error([err])
      }
    }

    "@params" <> rest -> {
      let start_pos = pos
      let pos = advance_pos_str(pos, "@params")
      case parse_params(rest, start_pos, pos) {
        Ok(#(token, remaining, new_pos)) ->
          tokenize_loop(remaining, new_pos, [token, ..tokens])
        Error(err) -> Error([err])
      }
    }

    // HTML comment: <!-- ... -->
    "<!--" <> rest -> {
      let pos = advance_pos_str(pos, "<!--")
      case skip_html_comment(rest, pos) {
        Ok(#(remaining, new_pos)) -> tokenize_loop(remaining, new_pos, tokens)
        Error(err) -> Error([err])
      }
    }

    // HTML closing tag: </tag>
    "</" <> rest -> {
      let start_pos = pos
      let pos = advance_pos_str(pos, "</")
      case parse_close_tag(rest, start_pos, pos) {
        Ok(#(token, remaining, new_pos)) ->
          tokenize_loop(remaining, new_pos, [token, ..tokens])
        Error(err) -> Error([err])
      }
    }

    // HTML opening tag: <tag ...>
    "<" <> rest -> {
      let start_pos = pos
      let pos = advance_pos(pos, "<")
      case parse_open_tag(rest, start_pos, pos) {
        Ok(#(token, remaining, new_pos)) ->
          tokenize_loop(remaining, new_pos, [token, ..tokens])
        Error(err) -> Error([err])
      }
    }

    // Control flow or expression: {#if}, {:else}, {/if}, {expr}
    "{" <> rest -> {
      let start_pos = pos
      let pos = advance_pos(pos, "{")
      case parse_brace_content(rest, start_pos, pos) {
        Ok(#(token, remaining, new_pos)) ->
          tokenize_loop(remaining, new_pos, [token, ..tokens])
        Error(err) -> Error([err])
      }
    }

    // Text content
    _ -> {
      let start_pos = pos
      let #(text, remaining, new_pos) = parse_text(input, "", pos)
      case text {
        "" -> {
          // No text was parsed, we're stuck - shouldn't happen but be safe
          case string.pop_grapheme(input) {
            Ok(#(_, rest)) -> tokenize_loop(rest, advance_pos(pos, "_"), tokens)
            Error(_) -> Ok(tokens)
          }
        }
        // Whitespace-only text is kept: the parser decides what it means
        // (a space between inline elements, or exact text inside <pre>)
        _ -> {
          let span = Span(start: start_pos, end: new_pos)
          let token = Text(content: text, span: span)
          tokenize_loop(remaining, new_pos, [token, ..tokens])
        }
      }
    }
  }
}

// === Position Tracking ===

fn advance_pos(pos: Position, char: String) -> Position {
  case char {
    "\n" -> Position(line: pos.line + 1, column: 1)
    _ -> Position(line: pos.line, column: pos.column + 1)
  }
}

fn advance_pos_str(pos: Position, str: String) -> Position {
  string.to_graphemes(str)
  |> list.fold(pos, advance_pos)
}

// === Import Parsing ===

fn parse_import(
  input: String,
  start_pos: Position,
  pos: Position,
) -> Result(#(Token, String, Position), ParseError) {
  case input {
    "(" <> rest -> {
      let pos = advance_pos(pos, "(")
      case extract_balanced_parens(rest, 0, "", pos) {
        Ok(#(content, remaining, end_pos)) -> {
          let span = Span(start: start_pos, end: end_pos)
          Ok(#(Import(content: content, span: span), remaining, end_pos))
        }
        Error(err) -> Error(err)
      }
    }
    _ ->
      Error(ParseError(Span(start: pos, end: pos), "Expected '(' after @import"))
  }
}

// === Params Parsing ===

fn parse_params(
  input: String,
  start_pos: Position,
  pos: Position,
) -> Result(#(Token, String, Position), ParseError) {
  case input {
    "(" <> rest -> {
      let pos = advance_pos(pos, "(")
      case extract_balanced_parens(rest, 0, "", pos) {
        Ok(#(content, remaining, end_pos)) -> {
          let params = parse_param_list(content)
          let span = Span(start: start_pos, end: end_pos)
          Ok(#(Params(params: params, span: span), remaining, end_pos))
        }
        Error(err) -> Error(err)
      }
    }
    _ ->
      Error(ParseError(Span(start: pos, end: pos), "Expected '(' after @params"))
  }
}

fn parse_param_list(content: String) -> List(#(String, String)) {
  content
  |> string.trim()
  |> split_params([], "", 0)
  |> list.filter_map(fn(param_str) {
    let param_str = string.trim(param_str)
    case param_str {
      "" -> Error(Nil)
      _ -> {
        case string.split_once(param_str, ":") {
          Ok(#(name, type_str)) ->
            Ok(#(string.trim(name), string.trim(type_str)))
          Error(_) -> Error(Nil)
        }
      }
    }
  })
}

fn split_params(
  input: String,
  acc: List(String),
  current: String,
  depth: Int,
) -> List(String) {
  case string.pop_grapheme(input) {
    Error(_) -> {
      case current {
        "" -> list.reverse(acc)
        _ -> list.reverse([current, ..acc])
      }
    }
    Ok(#(char, rest)) -> {
      case char {
        "(" | "[" | "{" -> split_params(rest, acc, current <> char, depth + 1)
        ")" | "]" | "}" -> split_params(rest, acc, current <> char, depth - 1)
        "," if depth == 0 -> split_params(rest, [current, ..acc], "", 0)
        _ -> split_params(rest, acc, current <> char, depth)
      }
    }
  }
}

// === HTML Tag Parsing ===

fn parse_close_tag(
  input: String,
  start_pos: Position,
  pos: Position,
) -> Result(#(Token, String, Position), ParseError) {
  let #(tag_name, rest, new_pos) = extract_tag_name(input, "", pos)
  case tag_name {
    "" -> Error(ParseError(Span(start: pos, end: pos), "Expected tag name"))
    _ -> {
      // Skip whitespace and find closing >
      let #(rest, new_pos) = skip_whitespace(rest, new_pos)
      case rest {
        ">" <> remaining -> {
          let end_pos = advance_pos(new_pos, ">")
          let span = Span(start: start_pos, end: end_pos)
          Ok(#(HtmlClose(tag: tag_name, span: span), remaining, end_pos))
        }
        _ ->
          Error(ParseError(
            Span(start: new_pos, end: new_pos),
            "Expected '>' in closing tag",
          ))
      }
    }
  }
}

fn parse_open_tag(
  input: String,
  start_pos: Position,
  pos: Position,
) -> Result(#(Token, String, Position), ParseError) {
  let #(tag_name, rest, new_pos) = extract_tag_name(input, "", pos)
  case tag_name {
    "" -> Error(ParseError(Span(start: pos, end: pos), "Expected tag name"))
    _ -> {
      // Parse attributes
      case parse_attributes(rest, new_pos, []) {
        Ok(#(attrs, remaining, attr_end_pos)) -> {
          // Check for self-closing or regular closing
          let #(remaining, attr_end_pos) =
            skip_whitespace(remaining, attr_end_pos)
          case remaining {
            "/>" <> after -> {
              let end_pos = advance_pos_str(attr_end_pos, "/>")
              let span = Span(start: start_pos, end: end_pos)
              Ok(#(
                HtmlOpen(
                  tag: tag_name,
                  attrs: list.reverse(attrs),
                  self_closing: True,
                  span: span,
                ),
                after,
                end_pos,
              ))
            }
            ">" <> after -> {
              let end_pos = advance_pos(attr_end_pos, ">")
              let span = Span(start: start_pos, end: end_pos)
              Ok(#(
                HtmlOpen(
                  tag: tag_name,
                  attrs: list.reverse(attrs),
                  self_closing: False,
                  span: span,
                ),
                after,
                end_pos,
              ))
            }
            _ ->
              Error(ParseError(
                Span(start: attr_end_pos, end: attr_end_pos),
                "Expected '>' or '/>' to close tag",
              ))
          }
        }
        Error(err) -> Error(err)
      }
    }
  }
}

fn extract_tag_name(
  input: String,
  acc: String,
  pos: Position,
) -> #(String, String, Position) {
  case string.pop_grapheme(input) {
    Error(_) -> #(acc, input, pos)
    Ok(#(char, rest)) -> {
      case is_tag_name_char(char) {
        True -> extract_tag_name(rest, acc <> char, advance_pos(pos, char))
        False -> #(acc, input, pos)
      }
    }
  }
}

const tag_name_chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_"

fn is_tag_name_char(char: String) -> Bool {
  string.contains(tag_name_chars, char)
}

// === Attribute Parsing ===

fn parse_attributes(
  input: String,
  pos: Position,
  attrs: List(Attribute),
) -> Result(#(List(Attribute), String, Position), ParseError) {
  let #(input, pos) = skip_whitespace(input, pos)

  // Check if we've reached the end of attributes
  case input {
    ">" <> _ | "/>" <> _ | "" -> Ok(#(attrs, input, pos))
    _ -> {
      // Try to parse an attribute
      case parse_single_attribute(input, pos) {
        Ok(#(attr, remaining, new_pos)) ->
          parse_attributes(remaining, new_pos, [attr, ..attrs])
        Error(err) -> Error(err)
      }
    }
  }
}

fn parse_single_attribute(
  input: String,
  pos: Position,
) -> Result(#(Attribute, String, Position), ParseError) {
  case input {
    // Spread: {...attrs}
    "{..." <> rest -> {
      let start_pos = pos
      let pos = advance_pos_str(pos, "{...")
      case extract_expression(rest, 0, "", pos) {
        Ok(#(expr, remaining, end_pos)) ->
          case string.trim(expr) {
            "" ->
              Error(ParseError(
                Span(start: start_pos, end: end_pos),
                "Expected an expression after {...",
              ))
            expr -> Ok(#(SpreadAttribute(expr:), remaining, end_pos))
          }
        Error(err) -> Error(err)
      }
    }

    // DOM property: .name={json}
    "." <> rest -> {
      let start_pos = pos
      let pos = advance_pos(pos, ".")
      let #(name, rest, new_pos) = extract_attr_name(rest, "", pos)
      case name, rest {
        "", _ ->
          Error(ParseError(
            Span(start: start_pos, end: new_pos),
            "Expected a property name after '.'",
          ))
        _, "={" <> after -> {
          let new_pos = advance_pos_str(new_pos, "={")
          case extract_expression(after, 0, "", new_pos) {
            Ok(#(expr, remaining, end_pos)) ->
              Ok(#(PropertyAttribute(name:, expr:), remaining, end_pos))
            Error(err) -> Error(err)
          }
        }
        _, _ ->
          Error(ParseError(
            Span(start: start_pos, end: new_pos),
            "A DOM property needs a Json expression: ." <> name <> "={json}",
          ))
      }
    }

    // Event attribute: @event={handler} or @event.prevent.stop={handler}
    "@" <> rest -> {
      let pos = advance_pos(pos, "@")
      let #(event_name, rest, new_pos) = extract_attr_name(rest, "", pos)
      // Parse optional .prevent and .stop modifiers
      case parse_event_modifiers(rest, new_pos, []) {
        Ok(#(modifiers, rest, new_pos)) -> {
          case rest {
            "={" <> after -> {
              let new_pos = advance_pos_str(new_pos, "={")
              case extract_expression(after, 0, "", new_pos) {
                Ok(#(handler, remaining, end_pos)) ->
                  Ok(#(
                    EventAttribute(
                      event: event_name,
                      handler: handler,
                      modifiers: modifiers,
                    ),
                    remaining,
                    end_pos,
                  ))
                Error(err) -> Error(err)
              }
            }
            _ ->
              Error(ParseError(
                Span(start: new_pos, end: new_pos),
                "Expected '={' after event attribute name",
              ))
          }
        }
        Error(err) -> Error(err)
      }
    }

    // Regular attribute
    _ -> {
      let #(attr_name, rest, new_pos) = extract_attr_name(input, "", pos)
      case attr_name {
        "" ->
          Error(ParseError(
            Span(start: pos, end: pos),
            "Expected attribute name",
          ))
        _ -> {
          case rest {
            // Dynamic attribute: name={expr}
            "={" <> after -> {
              let new_pos = advance_pos_str(new_pos, "={")
              case extract_expression(after, 0, "", new_pos) {
                Ok(#(expr, remaining, end_pos)) ->
                  Ok(#(
                    DynamicAttribute(name: attr_name, expr: expr),
                    remaining,
                    end_pos,
                  ))
                Error(err) -> Error(err)
              }
            }

            // Static attribute: name="value"
            "=\"" <> after -> {
              let new_pos = advance_pos_str(new_pos, "=\"")
              case extract_quoted_value(after, "", new_pos) {
                Ok(#(value, remaining, end_pos)) ->
                  Ok(#(
                    StaticAttribute(name: attr_name, value: value),
                    remaining,
                    end_pos,
                  ))
                Error(err) -> Error(err)
              }
            }

            // Static attribute with single quotes: name='value'
            "='" <> after -> {
              let new_pos = advance_pos_str(new_pos, "='")
              case extract_single_quoted_value(after, "", new_pos) {
                Ok(#(value, remaining, end_pos)) ->
                  Ok(#(
                    StaticAttribute(name: attr_name, value: value),
                    remaining,
                    end_pos,
                  ))
                Error(err) -> Error(err)
              }
            }

            // Boolean attribute (no value)
            _ -> Ok(#(BooleanAttribute(name: attr_name), rest, new_pos))
          }
        }
      }
    }
  }
}

fn extract_attr_name(
  input: String,
  acc: String,
  pos: Position,
) -> #(String, String, Position) {
  case string.pop_grapheme(input) {
    Error(_) -> #(acc, input, pos)
    Ok(#(char, rest)) -> {
      case is_attr_name_char(char) {
        True -> extract_attr_name(rest, acc <> char, advance_pos(pos, char))
        False -> #(acc, input, pos)
      }
    }
  }
}

fn is_attr_name_char(char: String) -> Bool {
  is_tag_name_char(char) || char == ":"
}

/// Parse event modifiers like .prevent and .stop after event name
fn parse_event_modifiers(
  input: String,
  pos: Position,
  modifiers: List(String),
) -> Result(#(List(String), String, Position), ParseError) {
  case input {
    ".prevent" <> rest -> {
      let new_pos = advance_pos_str(pos, ".prevent")
      parse_event_modifiers(rest, new_pos, list.append(modifiers, ["prevent"]))
    }
    ".stop" <> rest -> {
      let new_pos = advance_pos_str(pos, ".stop")
      parse_event_modifiers(rest, new_pos, list.append(modifiers, ["stop"]))
    }
    "." <> _ -> {
      Error(ParseError(
        Span(start: pos, end: pos),
        "Unknown event modifier (expected 'prevent' or 'stop')",
      ))
    }
    _ -> Ok(#(modifiers, input, pos))
  }
}

fn extract_quoted_value(
  input: String,
  acc: String,
  pos: Position,
) -> Result(#(String, String, Position), ParseError) {
  case string.pop_grapheme(input) {
    Error(_) ->
      Error(ParseError(Span(start: pos, end: pos), "Unterminated string"))
    Ok(#("\"", rest)) -> {
      let end_pos = advance_pos(pos, "\"")
      Ok(#(acc, rest, end_pos))
    }
    Ok(#("\\", rest)) -> {
      case string.pop_grapheme(rest) {
        Ok(#(escaped, rest2)) -> {
          let new_pos = advance_pos(advance_pos(pos, "\\"), escaped)
          extract_quoted_value(rest2, acc <> escaped, new_pos)
        }
        Error(_) ->
          Error(ParseError(Span(start: pos, end: pos), "Unterminated escape"))
      }
    }
    Ok(#(char, rest)) ->
      extract_quoted_value(rest, acc <> char, advance_pos(pos, char))
  }
}

fn extract_single_quoted_value(
  input: String,
  acc: String,
  pos: Position,
) -> Result(#(String, String, Position), ParseError) {
  case string.pop_grapheme(input) {
    Error(_) ->
      Error(ParseError(Span(start: pos, end: pos), "Unterminated string"))
    Ok(#("'", rest)) -> {
      let end_pos = advance_pos(pos, "'")
      Ok(#(acc, rest, end_pos))
    }
    Ok(#("\\", rest)) -> {
      case string.pop_grapheme(rest) {
        Ok(#(escaped, rest2)) -> {
          let new_pos = advance_pos(advance_pos(pos, "\\"), escaped)
          extract_single_quoted_value(rest2, acc <> escaped, new_pos)
        }
        Error(_) ->
          Error(ParseError(Span(start: pos, end: pos), "Unterminated escape"))
      }
    }
    Ok(#(char, rest)) ->
      extract_single_quoted_value(rest, acc <> char, advance_pos(pos, char))
  }
}

// === Brace Content Parsing (Expressions and Control Flow) ===

fn parse_brace_content(
  input: String,
  start_pos: Position,
  pos: Position,
) -> Result(#(Token, String, Position), ParseError) {
  case input {
    // Control flow: {#if condition}
    "#if " <> rest -> {
      let pos = advance_pos_str(pos, "#if ")
      case extract_expression(rest, 0, "", pos) {
        Ok(#(condition, remaining, end_pos)) -> {
          let span = Span(start: start_pos, end: end_pos)
          Ok(#(
            IfStart(condition: string.trim(condition), span: span),
            remaining,
            end_pos,
          ))
        }
        Error(err) -> Error(err)
      }
    }

    // Else: {:else}
    ":else}" <> rest -> {
      let end_pos = advance_pos_str(pos, ":else}")
      let span = Span(start: start_pos, end: end_pos)
      Ok(#(Else(span: span), rest, end_pos))
    }

    // End if: {/if}
    "/if}" <> rest -> {
      let end_pos = advance_pos_str(pos, "/if}")
      let span = Span(start: start_pos, end: end_pos)
      Ok(#(IfEnd(span: span), rest, end_pos))
    }

    // Each: {#each collection as item} or {#each collection as item, index}
    "#each " <> rest -> {
      let pos = advance_pos_str(pos, "#each ")
      case parse_each_header(rest, pos) {
        Ok(#(collection, item, index, key, remaining, end_pos)) -> {
          let span = Span(start: start_pos, end: end_pos)
          Ok(#(
            EachStart(
              collection: collection,
              item: item,
              index: index,
              key: key,
              span: span,
            ),
            remaining,
            end_pos,
          ))
        }
        Error(err) -> Error(err)
      }
    }

    // Call: {#call f(args)} or {#call f(args) as name}
    "#call " <> rest -> {
      let pos = advance_pos_str(pos, "#call ")
      case extract_expression(rest, 0, "", pos) {
        Ok(#(content, remaining, end_pos)) -> {
          let span = Span(start: start_pos, end: end_pos)
          case parse_call_header(string.trim(content)) {
            Ok(#(expr, label)) ->
              Ok(#(CallStart(expr:, label:, span:), remaining, end_pos))
            Error(message) -> Error(ParseError(span, message))
          }
        }
        Error(err) -> Error(err)
      }
    }

    // End call: {/call}
    "/call}" <> rest -> {
      let end_pos = advance_pos_str(pos, "/call}")
      let span = Span(start: start_pos, end: end_pos)
      Ok(#(CallEnd(span: span), rest, end_pos))
    }

    // End each: {/each}
    "/each}" <> rest -> {
      let end_pos = advance_pos_str(pos, "/each}")
      let span = Span(start: start_pos, end: end_pos)
      Ok(#(EachEnd(span: span), rest, end_pos))
    }

    // Case: {#case expr}
    "#case " <> rest -> {
      let pos = advance_pos_str(pos, "#case ")
      case extract_expression(rest, 0, "", pos) {
        Ok(#(expr, remaining, end_pos)) -> {
          let span = Span(start: start_pos, end: end_pos)
          Ok(#(
            CaseStart(expr: string.trim(expr), span: span),
            remaining,
            end_pos,
          ))
        }
        Error(err) -> Error(err)
      }
    }

    // Case pattern: {:Pattern} or {:Pattern(x)}
    ":" <> rest -> {
      let pos = advance_pos(pos, ":")
      case extract_pattern(rest, "", pos) {
        Ok(#(pattern, remaining, end_pos)) -> {
          let span = Span(start: start_pos, end: end_pos)
          Ok(#(CasePattern(pattern: pattern, span: span), remaining, end_pos))
        }
        Error(err) -> Error(err)
      }
    }

    // End case: {/case}
    "/case}" <> rest -> {
      let end_pos = advance_pos_str(pos, "/case}")
      let span = Span(start: start_pos, end: end_pos)
      Ok(#(CaseEnd(span: span), rest, end_pos))
    }

    // Embed directives: {@element expr}, {@elements expr}, {@html expr}
    "@html " <> rest -> parse_embed(EmbedHtml, "@html", rest, start_pos, pos)
    "@elements " <> rest ->
      parse_embed(EmbedElements, "@elements", rest, start_pos, pos)
    "@element " <> rest ->
      parse_embed(EmbedElement, "@element", rest, start_pos, pos)
    "@" <> _ -> {
      let #(name, _, _) =
        extract_attr_name(string.drop_start(input, 1), "", pos)
      Error(ParseError(
        Span(start: start_pos, end: pos),
        "Unknown directive {@"
          <> name
          <> "}. Expected {@element expr}, {@elements expr} or {@html expr}",
      ))
    }

    // Regular expression: {expr}
    _ -> {
      case extract_expression(input, 0, "", pos) {
        Ok(#(expr, remaining, end_pos)) -> {
          let span = Span(start: start_pos, end: end_pos)
          Ok(#(Expr(content: expr, span: span), remaining, end_pos))
        }
        Error(err) -> Error(err)
      }
    }
  }
}

/// Parse the expression of an embed directive such as `{@element expr}`.
/// `directive` is the text after `{`, used for position tracking and errors.
fn parse_embed(
  kind: EmbedKind,
  directive: String,
  input: String,
  start_pos: Position,
  pos: Position,
) -> Result(#(Token, String, Position), ParseError) {
  let pos = advance_pos_str(pos, directive <> " ")
  case extract_expression(input, 0, "", pos) {
    Ok(#(expr, remaining, end_pos)) -> {
      let span = Span(start: start_pos, end: end_pos)
      case string.trim(expr) {
        "" ->
          Error(ParseError(span, "Expected an expression after {" <> directive))
        expr -> Ok(#(Embed(kind:, content: expr, span:), remaining, end_pos))
      }
    }
    Error(err) -> Error(err)
  }
}

/// Split `f(args) as name` into the call and the optional argument name.
/// The call must end with `)`; `name` must be a lowercase Gleam name.
fn parse_call_header(
  content: String,
) -> Result(#(String, Option(String)), String) {
  let #(expr, label) = case string.ends_with(content, ")") {
    True -> #(content, None)
    False ->
      case list.reverse(string.split(content, " as ")) {
        [name, last_call_part, ..before] -> #(
          string.trim(string.join(
            list.reverse([last_call_part, ..before]),
            " as ",
          )),
          Some(string.trim(name)),
        )
        _ -> #(content, None)
      }
  }
  case string.ends_with(expr, ")") && string.contains(expr, "(") {
    False ->
      Error(
        "{#call} needs a function call, for example {#call layout.render(title)}",
      )
    True ->
      case label {
        Some(name) ->
          case is_lower_name(name) {
            True -> Ok(#(expr, label))
            False ->
              Error(
                "Expected a lowercase argument name after 'as' in {#call}, found '"
                <> name
                <> "'",
              )
          }
        None -> Ok(#(expr, None))
      }
  }
}

/// A Gleam lowercase name: starts with a-z, then a-z, 0-9 or _
fn is_lower_name(name: String) -> Bool {
  case string.to_graphemes(name) {
    [] -> False
    [first, ..rest] ->
      string.contains("abcdefghijklmnopqrstuvwxyz", first)
      && list.all(rest, fn(char) {
        string.contains("abcdefghijklmnopqrstuvwxyz0123456789_", char)
      })
  }
}

fn parse_each_header(
  input: String,
  pos: Position,
) -> Result(
  #(String, String, Option(String), Option(String), String, Position),
  ParseError,
) {
  // Find " as " to split collection from binding
  case find_as_keyword(input, "", pos) {
    Ok(#(collection, rest, new_pos)) -> {
      // Parse item, optional index and optional key until closing brace
      let #(binding, rest, end_pos) =
        extract_until_close_brace(rest, "", new_pos)
      case parse_binding(binding) {
        Ok(#(item, index, key)) ->
          Ok(#(string.trim(collection), item, index, key, rest, end_pos))
        Error(message) ->
          Error(ParseError(Span(start: new_pos, end: end_pos), message))
      }
    }
    Error(err) -> Error(err)
  }
}

fn find_as_keyword(
  input: String,
  acc: String,
  pos: Position,
) -> Result(#(String, String, Position), ParseError) {
  case input {
    "" ->
      Error(ParseError(
        Span(start: pos, end: pos),
        "Expected 'as' keyword in each",
      ))
    " as " <> rest -> {
      let new_pos = advance_pos_str(pos, " as ")
      Ok(#(acc, rest, new_pos))
    }
    _ -> {
      case string.pop_grapheme(input) {
        Ok(#(char, rest)) ->
          find_as_keyword(rest, acc <> char, advance_pos(pos, char))
        Error(_) ->
          Error(ParseError(
            Span(start: pos, end: pos),
            "Expected 'as' keyword in each",
          ))
      }
    }
  }
}

fn extract_until_close_brace(
  input: String,
  acc: String,
  pos: Position,
) -> #(String, String, Position) {
  case string.pop_grapheme(input) {
    Error(_) -> #(acc, input, pos)
    Ok(#("}", rest)) -> {
      let end_pos = advance_pos(pos, "}")
      #(acc, rest, end_pos)
    }
    Ok(#(char, rest)) ->
      extract_until_close_brace(rest, acc <> char, advance_pos(pos, char))
  }
}

/// Parse the binding part of `{#each}`: `item`, `item, index`, with an
/// optional key in parentheses at the end: `item (key)` or `item, i (key)`.
/// The item can be a pattern such as `#(a, b)`.
fn parse_binding(
  binding: String,
) -> Result(#(String, Option(String), Option(String)), String) {
  let binding = string.trim(binding)
  let #(binding, key) = split_key(binding)
  case key {
    Some("") -> Error("Expected a key expression inside ( ) in {#each}")
    _ -> {
      let #(item, index) = case split_top_level_comma(binding) {
        Ok(#(item, index)) -> #(string.trim(item), Some(string.trim(index)))
        Error(_) -> #(binding, None)
      }
      Ok(#(item, index, key))
    }
  }
}

/// Split a trailing ` (key)` group from an each binding. A group is a key
/// only when whitespace comes before it, so `#(a, b)` stays a pattern.
fn split_key(binding: String) -> #(String, Option(String)) {
  case string.ends_with(binding, ")") {
    False -> #(binding, None)
    True -> {
      let chars = string.to_graphemes(binding) |> list.reverse
      case find_group_start(chars, 0, []) {
        Ok(#(inner, [" ", ..before])) -> #(
          string.trim_end(string.concat(list.reverse(before))),
          Some(string.trim(string.concat(inner))),
        )
        _ -> #(binding, None)
      }
    }
  }
}

/// Walk reversed graphemes back to the `(` that opens the final group.
/// Returns the group's inner graphemes (in order) and the reversed rest.
fn find_group_start(
  reversed: List(String),
  depth: Int,
  inner: List(String),
) -> Result(#(List(String), List(String)), Nil) {
  case reversed {
    [] -> Error(Nil)
    [")", ..rest] if depth == 0 -> find_group_start(rest, 1, inner)
    [")", ..rest] -> find_group_start(rest, depth + 1, [")", ..inner])
    ["(", ..rest] if depth == 1 -> Ok(#(inner, rest))
    ["(", ..rest] -> find_group_start(rest, depth - 1, ["(", ..inner])
    [char, ..rest] -> find_group_start(rest, depth, [char, ..inner])
  }
}

/// Split at the first comma that is not inside brackets.
fn split_top_level_comma(input: String) -> Result(#(String, String), Nil) {
  case split_params(input, [], "", 0) {
    [first, ..rest] if rest != [] -> Ok(#(first, string.join(rest, ",")))
    _ -> Error(Nil)
  }
}

fn extract_pattern(
  input: String,
  acc: String,
  pos: Position,
) -> Result(#(String, String, Position), ParseError) {
  case string.pop_grapheme(input) {
    Error(_) ->
      Error(ParseError(Span(start: pos, end: pos), "Unterminated pattern"))
    Ok(#("}", rest)) -> {
      let end_pos = advance_pos(pos, "}")
      Ok(#(acc, rest, end_pos))
    }
    Ok(#("(", rest)) -> {
      // Handle nested parens in pattern
      let new_pos = advance_pos(pos, "(")
      case extract_balanced_parens(rest, 0, "", new_pos) {
        Ok(#(inner, remaining, after_pos)) -> {
          extract_pattern(remaining, acc <> "(" <> inner <> ")", after_pos)
        }
        Error(err) -> Error(err)
      }
    }
    Ok(#(char, rest)) ->
      extract_pattern(rest, acc <> char, advance_pos(pos, char))
  }
}

// === Expression Extraction (with brace balancing) ===

fn extract_expression(
  input: String,
  depth: Int,
  acc: String,
  pos: Position,
) -> Result(#(String, String, Position), ParseError) {
  case string.pop_grapheme(input) {
    Error(_) ->
      Error(ParseError(
        Span(start: pos, end: pos),
        "Unexpected end of input while parsing expression",
      ))
    Ok(#("{", rest)) ->
      extract_expression(rest, depth + 1, acc <> "{", advance_pos(pos, "{"))
    Ok(#("}", rest)) -> {
      case depth {
        0 -> {
          let end_pos = advance_pos(pos, "}")
          Ok(#(acc, rest, end_pos))
        }
        _ ->
          extract_expression(rest, depth - 1, acc <> "}", advance_pos(pos, "}"))
      }
    }
    Ok(#("\"", rest)) -> {
      // Handle string literals to avoid counting braces inside strings
      let new_pos = advance_pos(pos, "\"")
      case extract_string_literal(rest, "", new_pos) {
        Ok(#(str, remaining, after_pos)) ->
          extract_expression(
            remaining,
            depth,
            acc <> "\"" <> str <> "\"",
            after_pos,
          )
        Error(err) -> Error(err)
      }
    }
    Ok(#("(", rest)) -> {
      // Handle parens to properly balance
      extract_expression(rest, depth, acc <> "(", advance_pos(pos, "("))
    }
    Ok(#(")", rest)) -> {
      extract_expression(rest, depth, acc <> ")", advance_pos(pos, ")"))
    }
    Ok(#(char, rest)) ->
      extract_expression(rest, depth, acc <> char, advance_pos(pos, char))
  }
}

fn extract_string_literal(
  input: String,
  acc: String,
  pos: Position,
) -> Result(#(String, String, Position), ParseError) {
  case string.pop_grapheme(input) {
    Error(_) ->
      Error(ParseError(
        Span(start: pos, end: pos),
        "Unterminated string literal",
      ))
    Ok(#("\\", rest)) -> {
      // Handle escape sequences
      case string.pop_grapheme(rest) {
        Ok(#(escaped, rest2)) -> {
          let new_pos = advance_pos(advance_pos(pos, "\\"), escaped)
          extract_string_literal(rest2, acc <> "\\" <> escaped, new_pos)
        }
        Error(_) ->
          Error(ParseError(
            Span(start: pos, end: pos),
            "Unterminated escape sequence",
          ))
      }
    }
    Ok(#("\"", rest)) -> {
      let end_pos = advance_pos(pos, "\"")
      Ok(#(acc, rest, end_pos))
    }
    Ok(#(char, rest)) ->
      extract_string_literal(rest, acc <> char, advance_pos(pos, char))
  }
}

// === Text Parsing ===

fn parse_text(
  input: String,
  acc: String,
  pos: Position,
) -> #(String, String, Position) {
  case input {
    // Escaped braces
    "{{" <> rest -> parse_text(rest, acc <> "{", advance_pos_str(pos, "{{"))
    "}}" <> rest -> parse_text(rest, acc <> "}", advance_pos_str(pos, "}}"))

    // Start of expression or control flow - stop here
    "{" <> _ -> #(acc, input, pos)

    // Start of HTML tag or comment - stop here
    "<" <> _ -> #(acc, input, pos)

    // Start of directive - stop here
    "@import" <> _ -> #(acc, input, pos)
    "@params" <> _ -> #(acc, input, pos)

    // Empty input
    "" -> #(acc, input, pos)

    // Regular character
    _ -> {
      case string.pop_grapheme(input) {
        Ok(#(char, rest)) ->
          parse_text(rest, acc <> char, advance_pos(pos, char))
        Error(_) -> #(acc, input, pos)
      }
    }
  }
}

// === HTML Comment Handling ===

fn skip_html_comment(
  input: String,
  pos: Position,
) -> Result(#(String, Position), ParseError) {
  case input {
    "" ->
      Error(ParseError(Span(start: pos, end: pos), "Unterminated HTML comment"))
    "-->" <> rest -> {
      let end_pos = advance_pos_str(pos, "-->")
      Ok(#(rest, end_pos))
    }
    _ -> {
      case string.pop_grapheme(input) {
        Ok(#(char, rest)) -> skip_html_comment(rest, advance_pos(pos, char))
        Error(_) ->
          Error(ParseError(
            Span(start: pos, end: pos),
            "Unterminated HTML comment",
          ))
      }
    }
  }
}

// === Utility Functions ===

fn skip_whitespace(input: String, pos: Position) -> #(String, Position) {
  case string.pop_grapheme(input) {
    Ok(#(" ", rest)) -> skip_whitespace(rest, advance_pos(pos, " "))
    Ok(#("\t", rest)) -> skip_whitespace(rest, advance_pos(pos, "\t"))
    Ok(#("\n", rest)) -> skip_whitespace(rest, advance_pos(pos, "\n"))
    Ok(#("\r", rest)) -> skip_whitespace(rest, advance_pos(pos, "\r"))
    _ -> #(input, pos)
  }
}

fn extract_balanced_parens(
  input: String,
  depth: Int,
  acc: String,
  pos: Position,
) -> Result(#(String, String, Position), ParseError) {
  case string.pop_grapheme(input) {
    Error(_) ->
      Error(ParseError(Span(start: pos, end: pos), "Unterminated parentheses"))
    Ok(#("(", rest)) ->
      extract_balanced_parens(
        rest,
        depth + 1,
        acc <> "(",
        advance_pos(pos, "("),
      )
    Ok(#(")", rest)) -> {
      case depth {
        0 -> {
          let end_pos = advance_pos(pos, ")")
          Ok(#(acc, rest, end_pos))
        }
        _ ->
          extract_balanced_parens(
            rest,
            depth - 1,
            acc <> ")",
            advance_pos(pos, ")"),
          )
      }
    }
    Ok(#("\"", rest)) -> {
      // Handle string literals
      let new_pos = advance_pos(pos, "\"")
      case extract_string_literal(rest, "", new_pos) {
        Ok(#(str, remaining, after_pos)) ->
          extract_balanced_parens(
            remaining,
            depth,
            acc <> "\"" <> str <> "\"",
            after_pos,
          )
        Error(err) -> Error(err)
      }
    }
    Ok(#(char, rest)) ->
      extract_balanced_parens(rest, depth, acc <> char, advance_pos(pos, char))
  }
}
