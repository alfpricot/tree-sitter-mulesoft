//! This crate provides DataWeave language support for the [tree-sitter][] parsing library.
//!
//! Typically, you will use the [LANGUAGE][] constant to add this language to a
//! tree-sitter [Parser][], and then use the parser to parse some code:
//!
//! ```
//! let code = "%dw 2.0\noutput application/json\n---\n{ a: 1 }";
//! let mut parser = tree_sitter::Parser::new();
//! let language = tree_sitter_dataweave::LANGUAGE;
//! parser
//!     .set_language(&language.into())
//!     .expect("Error loading DataWeave parser");
//! let tree = parser.parse(code, None).unwrap();
//! assert!(!tree.root_node().has_error());
//! ```
//!
//! [Parser]: https://docs.rs/tree-sitter/*/tree_sitter/struct.Parser.html
//! [tree-sitter]: https://tree-sitter.github.io/

use tree_sitter_language::LanguageFn;

unsafe extern "C" {
    fn tree_sitter_dataweave() -> *const ();
}

/// The tree-sitter [`LanguageFn`][LanguageFn] for this grammar.
///
/// [LanguageFn]: https://docs.rs/tree-sitter-language/*/tree_sitter_language/struct.LanguageFn.html
pub const LANGUAGE: LanguageFn = unsafe { LanguageFn::from_raw(tree_sitter_dataweave) };

/// The content of the [`node-types.json`][] file for this grammar.
///
/// [`node-types.json`]: https://tree-sitter.github.io/tree-sitter/using-parsers#static-node-types
pub const NODE_TYPES: &str = include_str!("../../src/node-types.json");

pub const HIGHLIGHTS_QUERY: &str = include_str!("../../queries/highlights.scm");

/// The exported C symbol name, `tree_sitter_dataweave`.
pub const SYMBOL_NAME: &str = "tree_sitter_dataweave";

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_can_load_grammar() {
        let mut parser = tree_sitter::Parser::new();
        parser
            .set_language(&LANGUAGE.into())
            .expect("Error loading DataWeave parser");
    }

    #[test]
    fn test_exports_the_expected_symbol() {
        let parser_c = include_str!("../../src/parser.c");
        assert!(
            parser_c.contains("tree_sitter_dataweave(void)"),
            "generated parser no longer exports tree_sitter_dataweave"
        );
    }

    #[test]
    fn test_parses_a_sample() {
        let mut parser = tree_sitter::Parser::new();
        parser.set_language(&LANGUAGE.into()).unwrap();
        let tree = parser
            .parse(
                "%dw 2.0\noutput application/json\n---\n{ message: \"hello\" }",
                None,
            )
            .unwrap();
        assert!(!tree.root_node().has_error());
    }

    #[test]
    fn test_highlights_query_compiles() {
        tree_sitter::Query::new(&LANGUAGE.into(), HIGHLIGHTS_QUERY)
            .expect("DataWeave highlights must match the exported grammar");
    }
}
