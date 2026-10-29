// @generated from kanban_board.ghtml
// @hash 6267fe2c040f6b82612ff40574972ee84b48f3f51338a9ec5b80948709d0812c
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import gleam/dynamic/decode
import gleam/int
import gleam/list
import lustre/attribute
import lustre/element.{type Element, none, text}
import lustre/element/html
import lustre/element/keyed
import lustre/event
import model.{
  type Task, type TaskStatus, Done, High, InProgress, Low, Medium, NoPriority,
  Todo,
}

pub fn render(
  todo_tasks todo_tasks: List(Task),
  in_progress_tasks in_progress_tasks: List(Task),
  done_tasks done_tasks: List(Task),
  on_task_click on_task_click: fn(String) -> msg,
  on_drag_start on_drag_start: fn(String) -> decode.Decoder(msg),
  on_drag_end on_drag_end: decode.Decoder(msg),
  on_drop on_drop: fn(TaskStatus) -> decode.Decoder(msg),
  on_dragover on_dragover: fn(TaskStatus) -> decode.Decoder(msg),
  is_drop_target is_drop_target: fn(TaskStatus) -> Bool,
) -> Element(msg) {
  html.div([attribute.class("grid grid-cols-1 md:grid-cols-3 gap-4 lg:gap-6")], [
    html.div(
      [
        attribute.class(case is_drop_target(Todo) {
          True ->
            "bg-gray-100 dark:bg-gray-800 rounded-lg p-4 ring-2 ring-blue-400 ring-inset"
          False -> "bg-gray-100 dark:bg-gray-800 rounded-lg p-4"
        }),
        attribute.attribute("data-drop-zone", "true"),
        event.prevent_default(event.on("dragover", on_dragover(Todo))),
        event.prevent_default(event.on("drop", on_drop(Todo))),
      ],
      [
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
                    attribute.attribute("draggable", "true"),
                    attribute.class(
                      "relative bg-white dark:bg-gray-700 p-3 rounded-lg shadow-sm cursor-pointer hover:shadow-md transition-shadow",
                    ),
                    event.on_click(on_task_click(task.id)),
                    event.on("dragstart", on_drag_start(task.id)),
                    event.on("dragend", on_drag_end),
                  ],
                  [
                    case task.priority {
                      High ->
                        html.span(
                          [
                            attribute.class(
                              "absolute top-2 right-2 w-2.5 h-2.5 rounded-full bg-red-500",
                            ),
                          ],
                          [],
                        )
                      Medium ->
                        html.span(
                          [
                            attribute.class(
                              "absolute top-2 right-2 w-2.5 h-2.5 rounded-full bg-orange-500",
                            ),
                          ],
                          [],
                        )
                      Low ->
                        html.span(
                          [
                            attribute.class(
                              "absolute top-2 right-2 w-2.5 h-2.5 rounded-full bg-purple-500",
                            ),
                          ],
                          [],
                        )
                      NoPriority -> html.span([], [])
                    },
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
      [
        attribute.class(case is_drop_target(InProgress) {
          True ->
            "bg-blue-50 dark:bg-blue-900/30 rounded-lg p-4 ring-2 ring-blue-400 ring-inset"
          False -> "bg-blue-50 dark:bg-blue-900/30 rounded-lg p-4"
        }),
        attribute.attribute("data-drop-zone", "true"),
        event.prevent_default(event.on("dragover", on_dragover(InProgress))),
        event.prevent_default(event.on("drop", on_drop(InProgress))),
      ],
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
                    attribute.attribute("draggable", "true"),
                    attribute.class(
                      "relative bg-white dark:bg-gray-700 p-3 rounded-lg shadow-sm cursor-pointer hover:shadow-md transition-shadow",
                    ),
                    event.on_click(on_task_click(task.id)),
                    event.on("dragstart", on_drag_start(task.id)),
                    event.on("dragend", on_drag_end),
                  ],
                  [
                    case task.priority {
                      High ->
                        html.span(
                          [
                            attribute.class(
                              "absolute top-2 right-2 w-2.5 h-2.5 rounded-full bg-red-500",
                            ),
                          ],
                          [],
                        )
                      Medium ->
                        html.span(
                          [
                            attribute.class(
                              "absolute top-2 right-2 w-2.5 h-2.5 rounded-full bg-orange-500",
                            ),
                          ],
                          [],
                        )
                      Low ->
                        html.span(
                          [
                            attribute.class(
                              "absolute top-2 right-2 w-2.5 h-2.5 rounded-full bg-purple-500",
                            ),
                          ],
                          [],
                        )
                      NoPriority -> html.span([], [])
                    },
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
      [
        attribute.class(case is_drop_target(Done) {
          True ->
            "bg-green-50 dark:bg-green-900/30 rounded-lg p-4 ring-2 ring-blue-400 ring-inset"
          False -> "bg-green-50 dark:bg-green-900/30 rounded-lg p-4"
        }),
        attribute.attribute("data-drop-zone", "true"),
        event.prevent_default(event.on("dragover", on_dragover(Done))),
        event.prevent_default(event.on("drop", on_drop(Done))),
      ],
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
                    attribute.attribute("draggable", "true"),
                    attribute.class(
                      "relative bg-white dark:bg-gray-700 p-3 rounded-lg shadow-sm cursor-pointer hover:shadow-md transition-shadow",
                    ),
                    event.on_click(on_task_click(task.id)),
                    event.on("dragstart", on_drag_start(task.id)),
                    event.on("dragend", on_drag_end),
                  ],
                  [
                    case task.priority {
                      High ->
                        html.span(
                          [
                            attribute.class(
                              "absolute top-2 right-2 w-2.5 h-2.5 rounded-full bg-red-500",
                            ),
                          ],
                          [],
                        )
                      Medium ->
                        html.span(
                          [
                            attribute.class(
                              "absolute top-2 right-2 w-2.5 h-2.5 rounded-full bg-orange-500",
                            ),
                          ],
                          [],
                        )
                      Low ->
                        html.span(
                          [
                            attribute.class(
                              "absolute top-2 right-2 w-2.5 h-2.5 rounded-full bg-purple-500",
                            ),
                          ],
                          [],
                        )
                      NoPriority -> html.span([], [])
                    },
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
