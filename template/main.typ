#import "@preview/itu-academic-document:0.1.0": academic-document, read-glossary-entries, read-glossary-entries

#import "@preview/glossarium:0.5.10": *
#show: make-glossary
#let glossary-entries = read-glossary-entries(yaml("glossary.yaml"))
#register-glossary(glossary-entries)

// --- Front page / document metadata ---

#show: academic-document.with(
  dark_mode: false,

  department: "Department of Computer Science",
  course_name: "Course Name",
  course_code: "Course Code",
  document_type: "Document Type",

  title: "A Typst Template for ITU",

  authors: (
    (
      name: "John Smith",
      email: "josm@itu.dk",
    ),
    (
      name: "Jane Doe",
      email: "jado@itu.dk",
    ),
    (
      name: "James Johnson",
      email: "jajo@itu.dk",
    ),
    (
      name: "Jennifer Brown",
      email: "jebr@itu.dk",
    ),
  ),
  author_columns: 2,

  advisers: (
    (
      name: "Dr. Jane Smith",
      email: "jsmi@itu.dk",
    ),
    (
      name: "Prof. John Doe",
      email: "jdoe@itu.dk",
    ),
    (
      name: "Prof. Robert Wilson",
      email: "rowi@itu.dk",
    ),
  ),
  adviser_columns: 3,

  abstract: include "sections/0_abstract.typ",
)



// --- Sections ---

#include "sections/1_introduction.typ"
#include "sections/2_background.typ"
#include "sections/3_analysis.typ"
#include "sections/4_discussion.typ"
#include "sections/5_conclusion.typ"
#include "sections/6_future_work.typ"



// --- end-of-document material ---

// Clear the page header for end-of-document pages, so glossary and
// bibliography pages render with a clean header/footer.
#set page(header: [])

// Glossary: print entries from `glossary.yaml`. Use `show-all: true`
// to list every glossary entry (useful for templates and demos).
#pagebreak(weak: true)
= Glossary
#print-glossary(
  glossary-entries,
  show-all: true, // enable this to show all entries
)

// Bibliography: reads `bib.yaml`.
#pagebreak(weak: true)
= Bibliography
#bibliography(
  "bib.yaml",
  style: "ieee",
  title: none,
  full: true, // enable this to show all references
)
