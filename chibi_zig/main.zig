const std = @import("std");

const TokenKind = enum {
    TK_PUNCT,
    TK_NUM,
    TK_EOF,
};

const Token = struct {
    kind: TokenKind,
        next: ?*Token,
        val: i32,
        loc: []u8,
        len: i32,
};


