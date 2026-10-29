// @generated from full.ghtml
// @hash e198fae57280ee7f235f24d06e404c6266de44d2c2aed0dd933db3f8dab91152
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import e2e/lustre/generated/types.{
  type Status, type User, Active, Inactive, Pending,
}
import gleam/int
import gleam/list
import lustre/attribute
import lustre/element.{type Element, fragment, text}
import lustre/element/html

pub fn render(
  user user: User,
  items items: List(String),
  status status: Status,
) -> Element(msg) {
  html.article([attribute.class("user-card")], [
    case user.is_admin {
      True -> html.span([attribute.class("badge")], [text("Admin")])
      False -> html.span([attribute.class("badge")], [text("User")])
    },
    html.ul([], [
      fragment(
        list.index_map(items, fn(item, i) {
          html.li([], [text(int.to_string(i)), text(": "), text(item)])
        }),
      ),
    ]),
    case status {
      Active -> html.span([attribute.class("status active")], [text("Active")])
      Inactive ->
        html.span([attribute.class("status inactive")], [text("Inactive")])
      Pending ->
        html.span([attribute.class("status pending")], [text("Pending")])
    },
  ])
}
