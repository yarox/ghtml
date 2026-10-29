//// Formatting of generated files with `gleam format`.
////
//// Code generation writes each render function on one line. Running the
//// Gleam formatter afterwards gives readable files. Formatting is best
//// effort: if `gleam` is not available or the code does not parse (for
//// example, a template expression has a syntax error), the files stay as
//// generated and the compiler reports the problem.

import gleam/string
import shellout

/// Format `paths` with `gleam format`. Returns the formatter's message on
/// failure.
pub fn format_files(paths: List(String)) -> Result(Nil, String) {
  case paths {
    [] -> Ok(Nil)
    _ ->
      case
        shellout.command(
          run: "gleam",
          with: ["format", ..paths],
          in: ".",
          opt: [],
        )
      {
        Ok(_) -> Ok(Nil)
        Error(#(_, message)) -> Error(string.trim(message))
      }
  }
}
