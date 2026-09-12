//! This crate provides RAML language support for the [tree-sitter][] parsing library.
//!
//! Typically, you will use the [LANGUAGE][] constant to add this language to a
//! tree-sitter [Parser][], and then use the parser to parse some code:
//!
//! ```
//! let code = "#%RAML 1.0\ntitle: My API\n";
//! let mut parser = tree_sitter::Parser::new();
//! let language = tree_sitter_raml::LANGUAGE;
//! parser
//!     .set_language(&language.into())
//!     .expect("Error loading RAML parser");
//! let tree = parser.parse(code, None).unwrap();
//! assert!(!tree.root_node().has_error());
//! ```
//!
//! [Parser]: https://docs.rs/tree-sitter/*/tree_sitter/struct.Parser.html
//! [tree-sitter]: https://tree-sitter.github.io/

use tree_sitter_language::LanguageFn;

unsafe extern "C" {
    fn tree_sitter_raml() -> *const ();
}

/// The tree-sitter [`LanguageFn`][LanguageFn] for this grammar.
///
/// [LanguageFn]: https://docs.rs/tree-sitter-language/*/tree_sitter_language/struct.LanguageFn.html
pub const LANGUAGE: LanguageFn = unsafe { LanguageFn::from_raw(tree_sitter_raml) };

/// The content of the [`node-types.json`][] file for this grammar.
///
/// [`node-types.json`]: https://tree-sitter.github.io/tree-sitter/using-parsers#static-node-types
pub const NODE_TYPES: &str = include_str!("../../src/node-types.json");

pub const HIGHLIGHTS_QUERY: &str = include_str!("../../queries/highlights.scm");

/// The exported C symbol name, `tree_sitter_raml`.
pub const SYMBOL_NAME: &str = "tree_sitter_raml";

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_can_load_grammar() {
        let mut parser = tree_sitter::Parser::new();
        parser
            .set_language(&LANGUAGE.into())
            .expect("Error loading RAML parser");
    }

    #[test]
    fn test_exports_the_expected_symbol() {
        let parser_c = include_str!("../../src/parser.c");
        assert!(
            parser_c.contains("tree_sitter_raml(void)"),
            "generated parser no longer exports tree_sitter_raml"
        );
        assert!(
            !parser_c.contains("tree_sitter_yaml("),
            "generated parser exports tree_sitter_yaml — the name field changed"
        );
    }

    #[test]
    fn test_parses_a_sample() {
        let mut parser = tree_sitter::Parser::new();
        parser.set_language(&LANGUAGE.into()).unwrap();
        let tree = parser
            .parse("#%RAML 1.0\ntitle: Test API\nversion: v1\n/users:\n  get:\n    description: Get users\n", None)
            .unwrap();
        assert!(!tree.root_node().has_error());
    }

    #[test]
    fn test_highlights_query_compiles() {
        tree_sitter::Query::new(&LANGUAGE.into(), HIGHLIGHTS_QUERY)
            .expect("RAML highlights must match the exported grammar");
    }

    #[test]
    fn test_deep_nesting_does_not_overflow_scanner_state() {
        let mut parser = tree_sitter::Parser::new();
        parser.set_language(&LANGUAGE.into()).unwrap();
        let mut source = String::from("#%RAML 1.0\n");
        for depth in 0..300 {
            source.push_str(&"  ".repeat(depth));
            source.push_str("nested:\n");
        }
        source.push_str(&"  ".repeat(300));
        source.push_str("value: true\n");
        // Extreme nesting can exceed the saved indentation state, but parsing
        // must finish without writing past Tree-sitter's serialization buffer.
        assert!(parser.parse(source, None).is_some());
    }
}
