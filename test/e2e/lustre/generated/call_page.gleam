// @generated from page.ghtml
// @hash f5de6666ce180d361272587a86bb19d01fa89c681813a3a9e37bb44415cd6a7b
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import e2e/lustre/generated/card
import e2e/lustre/generated/composition as layout
import gleam/list
import gleam/string
import lustre/attribute
import lustre/element.{type Element, fragment, text}
import lustre/element/html

pub fn render(users users: List(String)) -> Element(msg) {
  layout.render(title: "Users", sidebar: element.none(), children: [
    card.render(title: "List", body: [
      html.ul([], [
        fragment(list.map(users, fn(user) { html.li([], [text(user)]) })),
      ]),
    ]),
    html.p([attribute.class("count")], [
      text(string.inspect(list.length(users))),
      text(" users"),
    ]),
  ])
}
