#include <assert.h>
#include <stdio.h>
#include <string.h>

#include "../src/scanner.c"

static void test_serialization(unsigned depth) {
    Scanner *scanner = tree_sitter_raml_external_scanner_create();
    scanner->row = 42;
    scanner->col = 7;
    scanner->blk_imp_row = 40;
    scanner->blk_imp_col = 3;
    scanner->blk_imp_tab = 1;
    for (unsigned i = 0; i < depth; ++i) {
        push_ind(scanner, i % 2 ? IND_SEQ : IND_MAP, (int16_t)(i * 2));
    }

    // Start at an odd address to exercise serialization without alignment assumptions.
    _Alignas(int16_t) unsigned char storage[TREE_SITTER_SERIALIZATION_BUFFER_SIZE + 4];
    memset(storage, 0xa5, sizeof(storage));
    char *buffer = (char *)&storage[1];
    unsigned length = serialize(scanner, buffer);
    assert(length <= TREE_SITTER_SERIALIZATION_BUFFER_SIZE);
    assert(storage[0] == 0xa5);
    for (unsigned i = TREE_SITTER_SERIALIZATION_BUFFER_SIZE + 1; i < sizeof(storage); ++i) {
        assert(storage[i] == 0xa5);
    }
    unsigned capacity = (TREE_SITTER_SERIALIZATION_BUFFER_SIZE - 10) / 4;
    unsigned retained = depth < capacity ? depth : capacity;
    assert(length == 10 + retained * 4);

    Scanner *restored = tree_sitter_raml_external_scanner_create();
    deserialize(restored, buffer, length);
    assert(restored->row == scanner->row);
    assert(restored->col == scanner->col);
    assert(restored->blk_imp_row == scanner->blk_imp_row);
    assert(restored->blk_imp_col == scanner->blk_imp_col);
    assert(restored->blk_imp_tab == scanner->blk_imp_tab);
    assert(restored->ind_typ_stk.size == retained + 1);
    assert(restored->ind_len_stk.size == retained + 1);
    for (unsigned i = 0; i <= retained; ++i) {
        assert(restored->ind_typ_stk.contents[i] == scanner->ind_typ_stk.contents[i]);
        assert(restored->ind_len_stk.contents[i] == scanner->ind_len_stk.contents[i]);
    }
    tree_sitter_raml_external_scanner_destroy(restored);
    tree_sitter_raml_external_scanner_destroy(scanner);
}

static void test_invalid_lengths(void) {
    Scanner *scanner = tree_sitter_raml_external_scanner_create();
    for (unsigned length = 0; length <= TREE_SITTER_SERIALIZATION_BUFFER_SIZE + 2; ++length) {
        if (length >= 10 && length <= TREE_SITTER_SERIALIZATION_BUFFER_SIZE && (length - 10) % 4 == 0) {
            continue;
        }
        char *buffer = length ? calloc(length, 1) : NULL;
        scanner->row = 42;
        push_ind(scanner, IND_MAP, 2);
        deserialize(scanner, buffer, length);
        assert(scanner->row == 0);
        assert(scanner->blk_imp_row == -1);
        assert(scanner->ind_typ_stk.size == 1);
        assert(scanner->ind_len_stk.size == 1);
        free(buffer);
    }
    tree_sitter_raml_external_scanner_destroy(scanner);
}

int main(void) {
    const unsigned depths[] = {0, 1, 252, 253, 254, 300};
    for (unsigned i = 0; i < sizeof(depths) / sizeof(depths[0]); ++i) {
        test_serialization(depths[i]);
    }
    test_invalid_lengths();
    puts("RAML scanner serialization tests passed");
    return 0;
}
