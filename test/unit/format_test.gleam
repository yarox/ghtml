import ghtml
import ghtml/format
import ghtml/types
import gleam/string
import gleeunit/should
import simplifile

const project = ".test/format_test"

fn setup(template: String) -> String {
  let _ = simplifile.delete(project)
  let _ = simplifile.create_directory_all(project <> "/src")
  let _ = simplifile.write(project <> "/src/card.ghtml", template)
  project <> "/src/card.gleam"
}

pub fn generated_files_are_formatted_test() {
  let output =
    setup(
      "@params(title: String, body: String)\n<section class=\"card\"><h2>{title}</h2><p>{body}</p><footer>Footer text here</footer></section>",
    )
  let _ = ghtml.generate_all(project, False, types.Lustre)
  let assert Ok(code) = simplifile.read(output)
  // gleam format splits the long line into one element per line
  should.be_true(string.contains(code, "\n    html.h2([], [text(title)]),\n"))
  let _ = simplifile.delete(project)
}

pub fn format_files_with_no_paths_test() {
  format.format_files([])
  |> should.equal(Ok(Nil))
}

pub fn format_files_reports_invalid_code_test() {
  let _ = simplifile.create_directory_all(project)
  let path = project <> "/broken.gleam"
  let _ = simplifile.write(path, "pub fn x( {")
  format.format_files([path])
  |> should.be_error
  let _ = simplifile.delete(project)
}
