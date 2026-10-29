// @generated from user_badge.ghtml
// @hash e67650e197f638c04820bdb9377fb20b8c0cf4658482544ceb243c7e8149fecc
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/attribute
import lustre/element.{type Element, text}
import lustre/element/html

pub fn render(is_admin is_admin: Bool) -> Element(msg) {
  html.span([attribute.class("badge")], [
    case is_admin {
      True -> html.span([attribute.class("admin")], [text("Admin")])
      False -> html.span([attribute.class("member")], [text("Member")])
    },
  ])
}
