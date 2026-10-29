// @generated from kanban_board.ghtml
// @hash 5747c0bccfca42e97f827980be5b22fbfd8ae6120bd05a515db18adc35165ef7
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import gleam/int
import gleam/list
import lustre/attribute
import lustre/element.{type Element, none, text}
import lustre/element/html
import lustre/element/keyed
import lustre/event
import model.{type Task}

pub fn render(
  todo_tasks todo_tasks: List(Task),
  in_progress_tasks in_progress_tasks: List(Task),
  done_tasks done_tasks: List(Task),
  on_task_click on_task_click: fn(String) -> msg,
) -> Element(msg) {
  html.div([attribute.class("grid grid-cols-1 md:grid-cols-3 gap-4 lg:gap-6")], [
    html.div([attribute.class("bg-gray-100 dark:bg-gray-800 rounded-lg p-4")], [
      html.h2(
        [
          attribute.class(
            "font-semibold text-gray-700 dark:text-gray-200 mb-4 flex items-center gap-2",
          ),
        ],
        [
          html.span([attribute.class("w-3 h-3 rounded-full bg-gray-400")], []),
          text(" Todo "),
          html.span(
            [
              attribute.class(
                "ml-auto text-sm font-normal text-gray-500 dark:text-gray-400",
              ),
            ],
            [text(int.to_string(list.length(todo_tasks)))],
          ),
        ],
      ),
      html.div([attribute.class("space-y-3")], [
        keyed.fragment(
          list.map(todo_tasks, fn(task) {
            #(
              task.id,
              html.div(
                [
                  attribute.class(
                    "bg-white dark:bg-gray-700 p-3 rounded-lg shadow-sm cursor-pointer hover:shadow-md transition-shadow",
                  ),
                  event.on_click(on_task_click(task.id)),
                ],
                [
                  html.h3(
                    [
                      attribute.class(
                        "font-medium text-gray-900 dark:text-white",
                      ),
                    ],
                    [text(task.title)],
                  ),
                  case task.description != "" {
                    True ->
                      html.p(
                        [
                          attribute.class(
                            "text-sm text-gray-500 dark:text-gray-400 mt-1 line-clamp-2",
                          ),
                        ],
                        [text(task.description)],
                      )
                    False -> none()
                  },
                ],
              ),
            )
          }),
        ),
      ]),
    ]),
    html.div(
      [attribute.class("bg-blue-50 dark:bg-blue-900/30 rounded-lg p-4")],
      [
        html.h2(
          [
            attribute.class(
              "font-semibold text-gray-700 dark:text-gray-200 mb-4 flex items-center gap-2",
            ),
          ],
          [
            html.span([attribute.class("w-3 h-3 rounded-full bg-blue-500")], []),
            text(" In Progress "),
            html.span(
              [
                attribute.class(
                  "ml-auto text-sm font-normal text-gray-500 dark:text-gray-400",
                ),
              ],
              [text(int.to_string(list.length(in_progress_tasks)))],
            ),
          ],
        ),
        html.div([attribute.class("space-y-3")], [
          keyed.fragment(
            list.map(in_progress_tasks, fn(task) {
              #(
                task.id,
                html.div(
                  [
                    attribute.class(
                      "bg-white dark:bg-gray-700 p-3 rounded-lg shadow-sm cursor-pointer hover:shadow-md transition-shadow",
                    ),
                    event.on_click(on_task_click(task.id)),
                  ],
                  [
                    html.h3(
                      [
                        attribute.class(
                          "font-medium text-gray-900 dark:text-white",
                        ),
                      ],
                      [text(task.title)],
                    ),
                    case task.description != "" {
                      True ->
                        html.p(
                          [
                            attribute.class(
                              "text-sm text-gray-500 dark:text-gray-400 mt-1 line-clamp-2",
                            ),
                          ],
                          [text(task.description)],
                        )
                      False -> none()
                    },
                  ],
                ),
              )
            }),
          ),
        ]),
      ],
    ),
    html.div(
      [attribute.class("bg-green-50 dark:bg-green-900/30 rounded-lg p-4")],
      [
        html.h2(
          [
            attribute.class(
              "font-semibold text-gray-700 dark:text-gray-200 mb-4 flex items-center gap-2",
            ),
          ],
          [
            html.span(
              [attribute.class("w-3 h-3 rounded-full bg-green-500")],
              [],
            ),
            text(" Done "),
            html.span(
              [
                attribute.class(
                  "ml-auto text-sm font-normal text-gray-500 dark:text-gray-400",
                ),
              ],
              [text(int.to_string(list.length(done_tasks)))],
            ),
          ],
        ),
        html.div([attribute.class("space-y-3")], [
          keyed.fragment(
            list.map(done_tasks, fn(task) {
              #(
                task.id,
                html.div(
                  [
                    attribute.class(
                      "bg-white dark:bg-gray-700 p-3 rounded-lg shadow-sm cursor-pointer hover:shadow-md transition-shadow",
                    ),
                    event.on_click(on_task_click(task.id)),
                  ],
                  [
                    html.h3(
                      [
                        attribute.class(
                          "font-medium text-gray-900 dark:text-white line-through",
                        ),
                      ],
                      [text(task.title)],
                    ),
                    case task.description != "" {
                      True ->
                        html.p(
                          [
                            attribute.class(
                              "text-sm text-gray-400 mt-1 line-clamp-2",
                            ),
                          ],
                          [text(task.description)],
                        )
                      False -> none()
                    },
                  ],
                ),
              )
            }),
          ),
        ]),
      ],
    ),
  ])
}
