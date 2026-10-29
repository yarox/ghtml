// @generated from mobile_nav.ghtml
// @hash 2d3baa5f8d784070aa6fbdc3b2369b8fbca9f08d245395e131e81ea3bb67d870
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import lustre/attribute
import lustre/element.{type Element, fragment, text}
import lustre/element/html
import lustre/event
import model.{type View, KanbanView, ListView}

pub fn render(
  current_view current_view: View,
  on_view_change on_view_change: fn(View) -> msg,
  on_add_task on_add_task: fn() -> msg,
) -> Element(msg) {
  html.nav(
    [
      attribute.class(
        "bg-white dark:bg-gray-800 border-t border-gray-200 dark:border-gray-700 px-4 py-2 safe-area-pb",
      ),
    ],
    [
      html.div([attribute.class("flex items-center justify-around")], [
        html.button(
          [
            attribute.class("flex flex-col items-center py-2 px-4"),
            event.on_click(on_view_change(ListView)),
          ],
          [
            case current_view == ListView {
              True ->
                fragment([
                  html.span(
                    [
                      attribute.class(
                        "text-blue-600 dark:text-blue-400 text-2xl",
                      ),
                    ],
                    [text("List")],
                  ),
                  html.span(
                    [
                      attribute.class(
                        "text-xs text-blue-600 dark:text-blue-400 font-medium",
                      ),
                    ],
                    [text("List")],
                  ),
                ])
              False ->
                fragment([
                  html.span([attribute.class("text-gray-400 text-2xl")], [
                    text("List"),
                  ]),
                  html.span([attribute.class("text-xs text-gray-400")], [
                    text("List"),
                  ]),
                ])
            },
          ],
        ),
        html.button(
          [
            attribute.class(
              "flex items-center justify-center w-14 h-14 -mt-6 bg-blue-600 dark:bg-blue-500 rounded-full shadow-lg text-white text-2xl",
            ),
            event.on_click(on_add_task()),
          ],
          [text("+")],
        ),
        html.button(
          [
            attribute.class("flex flex-col items-center py-2 px-4"),
            event.on_click(on_view_change(KanbanView)),
          ],
          [
            case current_view == KanbanView {
              True ->
                fragment([
                  html.span(
                    [
                      attribute.class(
                        "text-blue-600 dark:text-blue-400 text-2xl",
                      ),
                    ],
                    [text("Board")],
                  ),
                  html.span(
                    [
                      attribute.class(
                        "text-xs text-blue-600 dark:text-blue-400 font-medium",
                      ),
                    ],
                    [text("Board")],
                  ),
                ])
              False ->
                fragment([
                  html.span([attribute.class("text-gray-400 text-2xl")], [
                    text("Board"),
                  ]),
                  html.span([attribute.class("text-xs text-gray-400")], [
                    text("Board"),
                  ]),
                ])
            },
          ],
        ),
      ]),
    ],
  )
}
