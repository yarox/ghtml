// @generated from sidebar.ghtml
// @hash a10bc7dffd501b3287766d8e3d3c93cce40624213ac52a07261ff15869c7f666
// DO NOT EDIT - regenerate with: gleam run -m ghtml

import gleam/int
import gleam/list
import gleam/option.{type Option, Some}
import lustre/attribute
import lustre/element.{type Element, text}
import lustre/element/html
import lustre/element/keyed
import lustre/event
import model.{type Project}

pub fn render(
  projects projects: List(Project),
  current_project current_project: Option(String),
  on_select_all on_select_all: fn() -> msg,
  on_select_project on_select_project: fn(String) -> msg,
  on_create_project on_create_project: fn() -> msg,
) -> Element(msg) {
  html.nav(
    [
      attribute.class(
        "h-full bg-white dark:bg-gray-800 border-r border-gray-200 dark:border-gray-700 flex flex-col",
      ),
    ],
    [
      html.div(
        [attribute.class("p-4 border-b border-gray-200 dark:border-gray-700")],
        [
          html.h1(
            [attribute.class("text-xl font-bold text-gray-900 dark:text-white")],
            [text("Task Manager")],
          ),
        ],
      ),
      html.div([attribute.class("flex-1 overflow-y-auto py-4")], [
        html.div([attribute.class("px-4 mb-4")], [
          html.h2(
            [
              attribute.class(
                "text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider mb-2",
              ),
            ],
            [text("Quick Filters")],
          ),
          html.ul([attribute.class("space-y-1")], [
            html.li([], [
              html.button(
                [
                  attribute.class(
                    "w-full flex items-center px-3 py-2 text-sm rounded-md hover:bg-gray-100 dark:hover:bg-gray-700 dark:text-gray-200",
                  ),
                  event.on_click(on_select_all()),
                ],
                [html.span([attribute.class("mr-3")], [text("All Tasks")])],
              ),
            ]),
          ]),
        ]),
        html.div([attribute.class("px-4")], [
          html.div([attribute.class("flex items-center justify-between mb-2")], [
            html.h2(
              [
                attribute.class(
                  "text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider",
                ),
              ],
              [text("Projects")],
            ),
            html.button(
              [
                attribute.class(
                  "text-gray-400 hover:text-gray-600 dark:hover:text-gray-200",
                ),
                event.on_click(on_create_project()),
              ],
              [html.span([], [text("+")])],
            ),
          ]),
          html.ul([attribute.class("space-y-1")], [
            keyed.fragment(
              list.map(projects, fn(project) {
                #(
                  project.id,
                  html.li([], [
                    html.button(
                      [
                        attribute.class(
                          "w-full flex items-center px-3 py-2 text-sm rounded-md hover:bg-gray-100 dark:hover:bg-gray-700",
                        ),
                        event.on_click(on_select_project(project.id)),
                      ],
                      [
                        case current_project == Some(project.id) {
                          True ->
                            html.span(
                              [
                                attribute.class(
                                  "font-medium text-blue-600 dark:text-blue-400",
                                ),
                              ],
                              [text(project.name)],
                            )
                          False ->
                            html.span(
                              [
                                attribute.class(
                                  "text-gray-700 dark:text-gray-300",
                                ),
                              ],
                              [text(project.name)],
                            )
                        },
                        html.span(
                          [attribute.class("ml-auto text-xs text-gray-400")],
                          [text(int.to_string(project.task_count))],
                        ),
                      ],
                    ),
                  ]),
                )
              }),
            ),
          ]),
        ]),
      ]),
    ],
  )
}
