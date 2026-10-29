// @generated from filter_bar.ghtml
// @hash 78d8375ca988dca8638984b3b603a1cdc98831436245c03486627afd8131b2ac
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import gleam/dynamic/decode
import lustre/attribute
import lustre/element.{type Element, element, text}
import lustre/element/html
import lustre/event
import model.{type Filter, All, Overdue, Today}

pub fn render(
  current_filter current_filter: Filter,
  on_filter_change on_filter_change: fn(Filter) -> msg,
  on_sort_change on_sort_change: decode.Decoder(msg),
) -> Element(msg) {
  html.div([attribute.class("flex flex-wrap items-center gap-3 mb-4")], [
    html.div([attribute.class("flex items-center gap-2")], [
      html.span([attribute.class("text-sm text-gray-500 dark:text-gray-400")], [
        text("Filter:"),
      ]),
      html.div([attribute.class("flex gap-1")], [
        html.button(
          [
            attribute.class("px-3 py-1 text-sm rounded-md"),
            event.on_click(on_filter_change(All)),
          ],
          [
            case current_filter == All {
              True ->
                html.span(
                  [
                    attribute.class(
                      "bg-blue-100 dark:bg-blue-900 text-blue-700 dark:text-blue-200 px-3 py-1 rounded-md",
                    ),
                  ],
                  [text("All")],
                )
              False ->
                html.span(
                  [
                    attribute.class(
                      "bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600 dark:text-gray-200 px-3 py-1 rounded-md",
                    ),
                  ],
                  [text("All")],
                )
            },
          ],
        ),
        html.button(
          [
            attribute.class("px-3 py-1 text-sm rounded-md"),
            event.on_click(on_filter_change(Today)),
          ],
          [
            case current_filter == Today {
              True ->
                html.span(
                  [
                    attribute.class(
                      "bg-blue-100 dark:bg-blue-900 text-blue-700 dark:text-blue-200 px-3 py-1 rounded-md",
                    ),
                  ],
                  [text("Today")],
                )
              False ->
                html.span(
                  [
                    attribute.class(
                      "bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600 dark:text-gray-200 px-3 py-1 rounded-md",
                    ),
                  ],
                  [text("Today")],
                )
            },
          ],
        ),
        html.button(
          [
            attribute.class("px-3 py-1 text-sm rounded-md"),
            event.on_click(on_filter_change(Overdue)),
          ],
          [
            case current_filter == Overdue {
              True ->
                html.span(
                  [
                    attribute.class(
                      "bg-blue-100 dark:bg-blue-900 text-blue-700 dark:text-blue-200 px-3 py-1 rounded-md",
                    ),
                  ],
                  [text("Overdue")],
                )
              False ->
                html.span(
                  [
                    attribute.class(
                      "bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600 dark:text-gray-200 px-3 py-1 rounded-md",
                    ),
                  ],
                  [text("Overdue")],
                )
            },
          ],
        ),
      ]),
    ]),
    html.div([attribute.class("flex items-center gap-2")], [
      html.span([attribute.class("text-sm text-gray-500 dark:text-gray-400")], [
        text("Sort:"),
      ]),
      element(
        "sl-select",
        [attribute.value("created"), event.on("sl-change", on_sort_change)],
        [
          element("sl-option", [attribute.value("created")], [text("Created")]),
          element("sl-option", [attribute.value("due_date")], [text("Due Date")]),
          element("sl-option", [attribute.value("priority")], [text("Priority")]),
          element("sl-option", [attribute.value("title")], [text("Title")]),
        ],
      ),
    ]),
  ])
}
