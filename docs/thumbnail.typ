#import "/src/lib.typ" as my-package: *

// #set page(height: auto, margin: 5mm, fill: none)

// style thumbnail for light and dark theme
#let theme = sys.inputs.at("theme", default: "light") == "dark";

#show: academic-document.with(
  dark-mode: theme,

  department: "Department of Computer Science",
  course-name: "Course Name",
  course-code: "Course Code",
  document-type: "Document Type",

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
  author-columns: 2,

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
  adviser-columns: 3,

  // abstract: include "../template/sections/0-abstract.typ",
)
