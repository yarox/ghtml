//// Decoding of HTML character references (`&amp;`, `&copy;`, `&#169;`,
//// `&#xA9;`) in template text and static attribute values.
////
//// Lustre escapes text when it renders, so a template that contains
//// `&amp;` must give Lustre the character `&`, not the text `&amp;`.
//// Named references outside the list below, and malformed references, are
//// kept as written.

import gleam/int
import gleam/list
import gleam/result
import gleam/string

/// Named references that are decoded. This covers the common ones; the full
/// HTML list has over 2000 names.
const named = [
  #("amp", "&"),
  #("lt", "<"),
  #("gt", ">"),
  #("quot", "\""),
  #("apos", "'"),
  #("nbsp", "\u{00A0}"),
  #("copy", "©"),
  #("reg", "®"),
  #("trade", "™"),
  #("hellip", "…"),
  #("mdash", "—"),
  #("ndash", "–"),
  #("lsquo", "‘"),
  #("rsquo", "’"),
  #("ldquo", "“"),
  #("rdquo", "”"),
  #("laquo", "«"),
  #("raquo", "»"),
  #("middot", "·"),
  #("bull", "•"),
  #("times", "×"),
  #("divide", "÷"),
  #("minus", "−"),
  #("plusmn", "±"),
  #("deg", "°"),
  #("micro", "µ"),
  #("para", "¶"),
  #("sect", "§"),
  #("euro", "€"),
  #("pound", "£"),
  #("yen", "¥"),
  #("cent", "¢"),
  #("larr", "←"),
  #("rarr", "→"),
  #("uarr", "↑"),
  #("darr", "↓"),
  #("harr", "↔"),
  #("check", "✓"),
  #("iexcl", "¡"),
  #("iquest", "¿"),
  #("shy", "\u{00AD}"),
  #("zwj", "\u{200D}"),
  #("zwnj", "\u{200C}"),
  #("thinsp", "\u{2009}"),
  #("ensp", "\u{2002}"),
  #("emsp", "\u{2003}"),
]

/// Replace character references in `text` with the characters they name.
pub fn decode(text: String) -> String {
  case string.split(text, "&") {
    [first, ..rest] ->
      list.fold(rest, first, fn(acc, piece) { acc <> decode_piece(piece) })
    [] -> text
  }
}

/// `piece` is the text after an `&`. Decode a reference at its start, or
/// put the `&` back.
fn decode_piece(piece: String) -> String {
  case string.split_once(piece, ";") {
    Ok(#(name, after)) ->
      case lookup(name) {
        Ok(char) -> char <> after
        Error(_) -> "&" <> piece
      }
    Error(_) -> "&" <> piece
  }
}

fn lookup(name: String) -> Result(String, Nil) {
  case name {
    "#x" <> hex | "#X" <> hex ->
      int.base_parse(hex, 16) |> result.try(codepoint)
    "#" <> decimal -> int.parse(decimal) |> result.try(codepoint)
    _ -> list.key_find(named, name)
  }
}

fn codepoint(value: Int) -> Result(String, Nil) {
  // A reference to NUL or an invalid code point stays as written
  case value > 0 {
    True ->
      string.utf_codepoint(value)
      |> result.map(fn(cp) { string.from_utf_codepoints([cp]) })
    False -> Error(Nil)
  }
}
