// ─── Header ───────────────────────────────────────────────────────────────────

// Returns true if `secondary_heading` appears after `main_heading` in the
// document (comparing page number, then vertical position).
#let is_after(secondary_heading, main_heading) = {
  let sec_pos = secondary_heading.location().position()
  let main_pos = main_heading.location().position()

  if sec_pos.at("page") > main_pos.at("page") {
    true
  } else if sec_pos.at("page") == main_pos.at("page") {
    sec_pos.at("y") > main_pos.at("y")
  } else {
    false
  }
}

// Renders a centered, small-caps header with a full-width rule beneath it.
// Used when a level-1 heading starts on the current page.
#let build_main_header(content) = {
  align(center, smallcaps(content))
  line(length: 100%)
}

// Renders a two-column header (chapter title left, section title right) with a
// full-width rule beneath it. Used when a sub-heading is the most recent heading.
#let build_secondary_header(main_content, secondary_content) = {
  smallcaps(main_content)
  h(1fr)
  emph(secondary_content)
  line(length: 100%)
}

// Selects the appropriate header for the current page at render time:
//   - If a level-1 heading starts on this page, show it centered.
//   - Otherwise, if the most recent sub-heading follows the most recent
//     level-1 heading, show the two-column secondary format.
//   - Otherwise, fall back to the centered level-1 heading.
#let create_dynamic_header() = {
  let loc = here()

  // Try to use level 1 heading from current page
  let next_main_heading = query(selector(heading).after(loc)).find(h => (
    h.location().page() == loc.page() and h.level == 1
  ))

  if next_main_heading != none {
    build_main_header(next_main_heading.body)
  } else {
    // Fall back to most recent level 1 heading
    let last_main_heading = query(selector(heading).before(loc)).filter(h => h.level == 1).last()

    // Find most recent secondary heading
    let previous_secondary_headings = query(selector(heading).before(loc)).filter(h => h.level > 1)

    let last_secondary_heading = if previous_secondary_headings.len() != 0 {
      previous_secondary_headings.last()
    } else {
      none
    }

    // Choose header format based on heading positions
    if last_secondary_heading != none and is_after(last_secondary_heading, last_main_heading) {
      build_secondary_header(last_main_heading.body, last_secondary_heading.body)
    } else {
      build_main_header(last_main_heading.body)
    }
  }
}

// ─── Footer ───────────────────────────────────────────────────────────────────

// Renders a full-width rule, a centered page counter, and a logo aligned to the
// right. Pass `show_page_total: false` to show only the current page number.
#let create_footer(logo_small, show_page_total: true) = {
  line(length: 100%)
  place(center + horizon)[
    #text(
      1.2em,
      counter(page).display(
        "1 / 1",
        both: show_page_total,
      ),
    )
  ]
  place(right + horizon, image(logo_small, width: 10%))
}

// ─── Page components ──────────────────────────────────────────────────────────

// Renders the title page: logo, department, course, document type, title,
// author grid, optional adviser grid, and date. Ends with a page break.
#let create_title_page(
  logo,
  logo_width,
  department,
  course_name,
  course_code,
  document_type,
  title,
  authors,
  author_columns,
  advisers,
  adviser_columns,
  font,
  date,
) = {
  set par(justify: false)

  v(1em)
  set text(font: ("Open Sans", font), lang: "en")

  // Logo
  if logo != none {
    align(center, image(logo, width: logo_width))
  }

  // Department and course information
  if department != none {
    align(center, text(1.4em, department))
  }

  let course = if course_name != none and course_code != none {
    course_name + " - " + course_code
  } else if course_code != none {
    course_code
  } else if course_name != none {
    course_name
  } else {
    ""
  }

  if course != "" {
    if department != none {
      v(-0.5em)
    }
    align(center, text(1.4em, course))
  }

  v(4em)
  set text(font: font, lang: "en")

  // Document type and title
  if document_type != none {
    align(center, text(1.6em, document_type))
    v(1em)
  } else {
    v(4em)
  }

  align(center, text(2.6em, weight: "bold", title))

  // Authors section
  align(
    center,
    [
      #line(length: 60%, stroke: 0.5pt + gray)
      #v(1em)
      #text(1.2em, smallcaps[By])
      #v(1em)
    ],
  )

  let author_columns = calc.min(author_columns, authors.len())
  grid(
    columns: (1fr,) * author_columns,
    gutter: 2em,
    ..authors.map(author => align(
      center,
      text(
        1.2em,
        [
          *#author.name* \
          #author.email
        ],
      ),
    ))
  )

  v(8em)

  // Advisers section (if any)
  if advisers.len() > 0 {
    align(center, text(1.2em, smallcaps[Advised by]))
    v(0.8em)

    let adviser_columns = calc.min(adviser_columns, advisers.len())
    grid(
      columns: (1fr,) * adviser_columns,
      gutter: 2em,
      ..advisers.map(adviser => align(
        center,
        text(
          1.2em,
          [
            *#adviser.name* \
            #adviser.email
          ],
        ),
      ))
    )
  }

  place(bottom + center, text(1.2em, date))

  set par(justify: true)

  pagebreak()
}

// Renders the abstract on its own page with roman-numeral page numbering,
// resets the page counter to 1, then page-breaks into the TOC.
#let create_abstract_page(abstract) = {
  set page(numbering: "I", number-align: center, margin: 10em)
  v(1fr)
  align(center, heading(outlined: false, numbering: none, text(0.85em, smallcaps[Abstract])))
  abstract
  v(1.618fr)

  counter(page).update(1)
  pagebreak()
}

// Renders the table of contents (up to depth 3) followed by a page break.
#let create_toc_page() = {
  outline(depth: 3)
  pagebreak()
}

// ─── Body helpers ─────────────────────────────────────────────────────────────

// Wraps `body` in a show rule that inserts a weak page break before every
// level-1 heading after the first one, keeping sections on fresh pages.
#let setup_section_page_breaks(body) = {
  let section_counter = counter("section-counter")

  show heading: it => {
    if it.level == 1 {
      let count = section_counter.get().at(0, default: 0)
      section_counter.step()

      if count > 0 {
        pagebreak(weak: true)
      }

      it
    } else {
      it
    }
  }

  body
}

// Validates and normalises a glossary dictionary (typically loaded from
// `glossary.yaml`) into the list of entry dictionaries expected by the
// glossarium package. Asserts on unknown keys or wrong value types.
#let read-glossary-entries(entries) = {
  let file_name = "glossary.yaml"

  assert(
    type(entries) == dictionary,
    message: "The glossary `" + file_name + "` is not a dictionary",
  )

  for (k, v) in entries.pairs() {
    assert(
      type(v) == dictionary,
      message: "The glossary entry `" + k + "` in `" + file_name + "` is not a dictionary",
    )

    for key in v.keys() {
      assert(
        key
          in (
            "short",
            "long",
            "description",
            "group",
            "plural",
            "longplural",
            "artshort",
            "artlong",
          ),
        message: "Found unexpected key `" + key + "` in glossary entry `" + k + "` in `" + file_name + "`",
      )
    }

    // assert(
    //   type(v.short) == str,
    //   message: "The short form of glossary entry `" + k + "` in `" + file + "` is not a string",
    // )

    if "long" in v {
      assert(
        type(v.long) == str,
        message: "The long form of glossary entry `" + k + "` in `" + file_name + "` is not a string",
      )
    }

    if "description" in v {
      assert(
        type(v.description) == str,
        message: "The description of glossary entry `" + k + "` in `" + file_name + "` is not a string",
      )
    }

    if "group" in v {
      assert(
        type(v.group) == str,
        message: "The optional group of glossary entry `" + k + "` in `" + file_name + "` is not a string",
      )
    }
  }

  return entries
    .pairs()
    .map(((key, entry)) => (
      key: key,
      short: eval(entry.at("short", default: ""), mode: "markup"),
      long: eval(entry.at("long", default: ""), mode: "markup"),
      description: eval(entry.at("description", default: ""), mode: "markup"),
      group: entry.at("group", default: ""),
      // file: file,
    ))
}

// ─── Main entry point ─────────────────────────────────────────────────────────

// The top-level template function. Call this from `main.typ` to apply all
// document styling and structure. Renders (in order):
//   1. Title page
//   2. Abstract page (roman numerals)
//   3. Table of contents
//   4. Body content with running header/footer (arabic numerals)
#let academic-document(
  logo: "logo/logo.png",
  logo_dark_mode: "logo/logo_dark_mode.png",
  logo_small: "logo/logo_small.png",
  logo_small_dark_mode: "logo/logo_small_dark_mode.png",
  logo_width: 70%,
  document_type: none,
  department: none,
  course_name: none,
  course_code: none,
  title: "",
  abstract: [],
  authors: (),
  author_columns: 3,
  advisers: (),
  adviser_columns: 3,
  font: "New Computer Modern",
  show_page_total: true,
  date: datetime.today().display("[month repr:long] [day], [year]"),
  page_break_after_sections: true,
  dark_mode: false,
  body,
) = {
  // Document metadata and base typography
  set document(author: authors.map(a => a.name), title: title)
  show math.equation: it => set text(weight: 400)
  set heading(numbering: "1.1")
  set par(justify: true, first-line-indent: 20pt)

  // Dark mode: invert page/text colours and adjust link and table stroke colours
  set page(fill: if dark_mode { black } else { white })
  set text(fill: if dark_mode { white } else { black })
  let link_fill = if dark_mode { blue.lighten(60%) } else { blue.darken(60%) }
  show link: set text(fill: link_fill)
  show ref: set text(fill: link_fill)
  set table(stroke: if dark_mode { white } else { black })

  // Create title page
  create_title_page(
    if dark_mode { logo_dark_mode } else { logo },
    logo_width,
    department,
    course_name,
    course_code,
    document_type,
    title,
    authors,
    author_columns,
    advisers,
    adviser_columns,
    font,
    date,
  )

  // Create abstract page
  create_abstract_page(abstract)

  // Create table of contents
  create_toc_page()

  // Switch to arabic page numbers with running header and footer
  set page(
    header: context create_dynamic_header(),
    footer: context create_footer(
      if dark_mode { logo_small_dark_mode } else { logo_small },
      show_page_total: show_page_total,
    ),
  )

  counter(page).update(1)

  set page(numbering: "1") // to change the numbering style, look at `create_footer`

  // Apply section page breaks and render body
  if page_break_after_sections {
    setup_section_page_breaks(body)
  } else {
    body
  }
}
