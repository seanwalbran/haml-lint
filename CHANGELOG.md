# HAML-Lint Changelog

## 0.9.0

* Fix bug in `LeadingCommentSpace` where empty comment lines would incorrectly
  report lints.
* Fix bug where any `haml` version 4.0.6 or later would not remove the special
  end-of-document marker from parse trees
* Fix bug where RuboCop's `Style/OneLineConditional` cop would incorrectly be
  reported for HAML code with `if`/`else` statements
* Fix bug where RuboCop's `Style/SymbolProc` cop would incorrectly be reported

## 0.8.0

* Fix bug in `ConsecutiveSilentScripts` where control statements with nested
  HAML would incorrectly be reported as silent scripts
* Fix bug in `ImplicitDiv` where incorrect lint would be reported for `div`
  tags with dynamic ids or classes
* Fix bug in `ClassAttributeWithStaticValue` where syntax errors in attributes
  would result in a crash
* Add `TrailingWhitespace` linter which checks for whitespace at the end of a line
* Fix bug where last statement of HAML document would be removed when using
  `haml` 4.1.0.beta.1
* Fix bug where `ObjectReferenceAttributes` would incorrectly report a bug for
  all tags when using `haml` 4.1.0.beta.1

## 0.7.0

* New lint `UnnecessaryInterpolation` checks for interpolation in inline
  tag content that can be written more concisely as just the expression
* New lint 'UnnecessaryStringOutput` checks for script output of literal
  strings that could be converted to regular text content
* New lint `ClassesBeforeIds` checks that classes are listed before IDs
  in tags
* Linter name is now included in output when error/warning reported
* New lint `RubyComments` checks for comments that can be converted to
  HAML comments
* New lint `EmptyScript` checks for empty scripts (e.g. `-` followed by
  nothing)
* New lint `LeadingCommentSpace` checks for a space after the `#` in
  comments
* Fix bug where including and excluding the same linter would result in a crash
* New lint `ConsecutiveComments` checks for consecutive comments that could be
  condensed into a single multiline comment
* New lint `ConsecutiveSilentScripts` checks for consecutive lines of Ruby code
  that could be condensed into a single `:ruby` filter block
* Fix bug in Linter::UnnecessaryStringOutput when tag is empty
* Add `skip_frontmatter` option to configuration which customizes whether
  frontmatter included at the beginning of HAML files in frameworks like
  Jekyll/Middleman are ignored
* Change parse tree hierarchy to use `HamlLint::Tree::Node` subclasses instead
  of the `Haml::Parser::ParseNode` struct to make working with it easier
* New lint `ObjectReferenceAttributes` checks for the use of the object
  reference syntax to set the class/id of an element
* New lint `HtmlAttributes` checks for the use of the HTML-style attributes
  syntax when defining attributes for an element
* New lint `ClassAttributeWithStaticValue` checks for assigning static values
  for class attributes in dynamic hashes

## 0.6.1

* Add rake task integration
* Fix broken `--help` switch
* Silence `LineLength` RuboCop check
* Upgrade Rubocop dependency to >= 0.25.0

## 0.6.0

* Fix crash when reporting a lint from Rubocop that did not include a line
  number
* Allow `haml-lint` to be configured via YAML file, either by automatically
  loading `.haml-lint.yml` if it exists, or via a configuration file
  explicitly passed in via the `--config` flag
* Update RuboCop dependency to >= 0.24.1
* Rename `RubyScript` linter to `RuboCop`
* Add customizable `LineLength` linter to check that the number of columns on
  each line in a file is no greater than some maximum amount (80 by default)
* Gracefully handle invalid file paths and return semantic error code

## 0.5.2

* Use >= 0.23.0 for RuboCop dependency

## 0.5.1

* Ignore the `Next` Rubocop cop
* Fix crash when reporting a lint inside string interpolation in a filter

## 0.5.0

* Ignore the `FileName` Rubocop cop
* Fix loading correct .rubocop.yml config

## 0.4.1

* Relax HAML dependency from `4.0.3` to `4.0`+

## 0.4.0

* Upgrade `rubocop` dependency from `0.15.0` to `0.16.0`
* Fix broken `--show-linters` flag
* Ignore `BlockAlignment`, `EndAlignment`, and `IndentationWidth` Rubocop lints
* Fix bug where `SpaceBeforeScript` linter would incorrectly report lints when
  the same substring appeared on a line underneath a tag with inline script

## 0.3.0

* Fix bug in `ScriptExtractor` where incorrect indentation would be generated
  for `:ruby` filters containing code with block keywords
* Differentiate between syntax errors and lint warnings by outputting severity
  level for lint (`E` and `W`, respectively).
* Upgrade `rubocop` dependency to `0.15.0`

## 0.2.0

* New lint `ImplicitDiv` `%div`s which are unnecessary due to a class or ID
  specified on the tag
* New lint `TagName` ensures tag names are lowercase
* Minimum version of Rubocop bumped to `0.13.0`
* New lint `MultilinePipe` ensures the pipe `|` character is never used for
  wrapping lines

## 0.1.0

* New lint `SpaceBeforeScript` ensures that Ruby code in HAML indicated with the
  `-` and `=` characters always has one space separating them from code
* New lint `RubyScript` integrates with [Rubocop](https://github.com/bbatsov/rubocop)
  to report lints supported by that tool (respecting any existing `.rubocop.yml`
  configuration)
