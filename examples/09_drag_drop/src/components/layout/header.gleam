// @generated from header.ghtml
// @hash f387e33b52c0acd7171bb8864e7bb5c57cf684eaf593eb207edbf01b76f45fda
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import gleam/dynamic/decode
import lustre/attribute
import lustre/element.{type Element, element, text}
import lustre/element/html
import lustre/event
import model.{type View, KanbanView, ListView}

pub fn render(
  current_view current_view: View,
  search_query search_query: String,
  dark_mode dark_mode: Bool,
  on_toggle_sidebar on_toggle_sidebar: fn() -> msg,
  on_view_change on_view_change: fn(View) -> msg,
  on_search_change on_search_change: decode.Decoder(msg),
  on_toggle_dark_mode on_toggle_dark_mode: fn() -> msg,
  on_add_task on_add_task: fn() -> msg,
) -> Element(msg) {
  html.header(
    [
      attribute.class(
        "bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700 px-4 py-3",
      ),
    ],
    [
      html.div([attribute.class("flex items-center justify-between")], [
        html.div([attribute.class("flex items-center gap-4")], [
          html.button(
            [
              attribute.class(
                "lg:hidden p-2 rounded-md hover:bg-gray-100 dark:hover:bg-gray-700 dark:text-gray-200",
              ),
              event.on_click(on_toggle_sidebar()),
            ],
            [html.span([attribute.class("text-xl")], [text("Menu")])],
          ),
          html.div([attribute.class("hidden sm:flex items-center gap-2")], [
            html.button(
              [
                attribute.class(
                  "px-3 py-1.5 text-sm rounded-md dark:text-gray-200",
                ),
                event.on_click(on_view_change(ListView)),
              ],
              [
                case current_view == ListView {
                  True ->
                    html.span(
                      [
                        attribute.class(
                          "bg-gray-200 dark:bg-gray-600 px-3 py-1.5 rounded-md",
                        ),
                      ],
                      [text("List")],
                    )
                  False ->
                    html.span(
                      [
                        attribute.class(
                          "hover:bg-gray-100 dark:hover:bg-gray-700 px-3 py-1.5 rounded-md",
                        ),
                      ],
                      [text("List")],
                    )
                },
              ],
            ),
            html.button(
              [
                attribute.class(
                  "px-3 py-1.5 text-sm rounded-md dark:text-gray-200",
                ),
                event.on_click(on_view_change(KanbanView)),
              ],
              [
                case current_view == KanbanView {
                  True ->
                    html.span(
                      [
                        attribute.class(
                          "bg-gray-200 dark:bg-gray-600 px-3 py-1.5 rounded-md",
                        ),
                      ],
                      [text("Board")],
                    )
                  False ->
                    html.span(
                      [
                        attribute.class(
                          "hover:bg-gray-100 dark:hover:bg-gray-700 px-3 py-1.5 rounded-md",
                        ),
                      ],
                      [text("Board")],
                    )
                },
              ],
            ),
          ]),
        ]),
        html.div([attribute.class("flex items-center gap-3")], [
          element(
            "sl-input",
            [
              attribute.class("w-48 sm:w-64"),
              attribute.placeholder("Search tasks..."),
              attribute.value(search_query),
              event.on("sl-input", on_search_change),
            ],
            [],
          ),
          element(
            "sl-tooltip",
            [
              attribute.attribute("content", case dark_mode {
                True -> "Switch to light mode"
                False -> "Switch to dark mode"
              }),
            ],
            [
              element(
                "sl-icon-button",
                [
                  attribute.name(case dark_mode {
                    True -> "sun"
                    False -> "moon"
                  }),
                  attribute.attribute("label", "Toggle dark mode"),
                  event.on_click(on_toggle_dark_mode()),
                  attribute.class("text-xl"),
                ],
                [],
              ),
            ],
          ),
          element(
            "sl-button",
            [
              attribute.attribute("variant", "primary"),
              event.on_click(on_add_task()),
            ],
            [html.span([], [text("+ Add Task")])],
          ),
        ]),
      ]),
    ],
  )
}
