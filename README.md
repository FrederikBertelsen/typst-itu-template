# ITU Typst Template for Academic Documents

Academic document template for [IT University of Copenhagen](https://itu.dk/), built with [Typst](https://typst.app/).

[View example PDF output](main.pdf)

## Features
- Customizable title page
- Automatic table of contents
- bibliography system for sources and references
- Glossary system for technical terms
- Dark mode

## Getting Started

1. **Font Installation (optional)**
   - The template uses Open Sans (ITU's logo font) for the title page
   - The template will fall back to system fonts if Open Sans isn't installed
   - Download from [Google Fonts](https://fonts.google.com/specimen/Open+Sans) if needed

2. **Configure your document**
   - Edit the project parameters in [`main.typ`](main.typ) to set your details:
     ```typst
     #show: project.with(
       department: "Department",
       course_name: "Course Name",
       course_code: "Course Code",
       document_type: "Document Type",
       title: "Your Document Title",
       authors: (...),
       max_author_columns: 2,
       advisers: (...),
       max_adviser_columns: 3,
     )
     ```

3. **Write your content**
   - The sections are split into files for organization (see the `sections` folder)
   - you can include new sections by adding them to the [`main.typ`](main.typ) file

> [!NOTE]
> You can enable dark mode if you prefer while you're working.

## Get Started with Typst

### Resources
- [Typst for LaTeX users](https://typst.app/docs/guides/guide-for-latex-users/)
- [Official Typst Documentation](https://typst.app/docs)
- [Typst Examples Book](https://sitandr.github.io/typst-examples-book/book/)
- [Awesome Typst](https://github.com/qjcg/awesome-typst)

### Installation
> [!NOTE]  
> There is also an online editor for Typst at [typst.app](https://typst.app/)

1. **Install Typst**
   - [Typst GitHub Repository](https://github.com/typst/typst?tab=readme-ov-file#installation)
   
2. **Editor Integration**
   - [TinyMist Extension](https://github.com/Myriad-Dreamin/tinymist?tab=readme-ov-file#installation) for VSCode, NeoVim, etc.

## Working with References

### Bibliography
- Add references to [`bib.yaml`](bib.yaml)
- Reference in text using `@citation_key` or `#ref(<citation_key>)`
- Bibliography generated automatically at document end
- Supports articles, books, proceedings, web resources, and more

### Glossary
- Define terms in [`glossary.yaml`](glossary.yaml) with short/long forms and descriptions
- Reference terms using `@term_key` syntax
- First usage shows full form, subsequent uses show short form
- Force full form with `#gls("term_key", long: true)`
- Use plural forms with `@term_key:pl` or `#glspl("term_key")`


## Credits
This template is built on the foundation provided by [Simple Typst Thesis](https://github.com/zagoli/simple-typst-thesis/) by Zagoli. 
The original work has been expanded with additional features, and ITU-specific styling.


