// @generated from todo_item.ghtml
// @hash bc596bd8680014c23a8ae497cf46737e1275dab9290dfaa2ce6c7b3348b82213
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/attribute
import lustre/element.{type Element, text}
import lustre/element/html
import lustre/event
import types.{type Todo, High, Low, Medium}

pub fn render(
  t t: Todo,
  on_toggle on_toggle: fn() -> msg,
  on_delete on_delete: fn() -> msg,
) -> Element(msg) {
  html.div([attribute.class("todo-item")], [
    html.input([
      attribute.type_("checkbox"),
      attribute.checked(t.completed),
      event.on_click(on_toggle()),
    ]),
    html.span([attribute.class("text")], [
      case t.completed {
        True -> html.s([], [text(t.text)])
        False -> text(t.text)
      },
    ]),
    case t.priority {
      High -> html.span([attribute.class("priority high")], [text("!")])
      Medium -> html.span([attribute.class("priority medium")], [text("-")])
      Low -> html.span([attribute.class("priority low")], [text(".")])
    },
    html.button([attribute.class("delete"), event.on_click(on_delete())], [
      text("x"),
    ]),
  ])
}
