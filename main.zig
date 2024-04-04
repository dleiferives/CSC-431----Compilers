const std = @import("std");

// LEXER
const TokenKind = enum {
    TK_INT,
    TK_ID,
    TK_WS,
    TK_COMMENT,
    TK_EOF,
};

const Token = struct {
    kind: TokenKind,
    literal: []const u8,
    value: i32 = 0,
    line: i32,
    col: i32,
    file: []const u8,
};

const Lexer = struct {
    line: i32,
    col: i32,
    file: []const u8,
    index: usize,
};

fn lex(source: []const u8, file: []const u8) ![]Token {
    var tokens = std.ArrayList(Token).init(std.heap.page_allocator);
    var lexer = Lexer{ .line = 0, .col = 0, .file = file, .index = 0 };
    while (lexer.index < source.len) {
        const start = lexer.index;
        _ = start;

        const res = switch (source[lexer.index]) {
            '0'...'9' => lexNumber(source, &lexer),
            'a'...'z', 'A'...'Z', '_' => lexIdentifier(source, &lexer),
            ' ', '\t', '\n', '\r' => lexWhitespace(source, &lexer),
            '#' => lexComment(source, &lexer),
            4, 0 => lexEOF(&lexer),
            else => return error.InvalidCharacter,
        } catch |err| return err;
        try tokens.append(res);
    }
    return tokens.toOwnedSlice();
}

fn lexEOF(lexer: *Lexer) !Token {
    return Token{ .kind = TokenKind.TK_EOF, .literal = "", .col = lexer.col, .line = lexer.line, .file = lexer.file };
}

fn lexIdentifier(source: []const u8, lexer: *Lexer) !Token {
    const start = lexer.index;
    while (lexer.index < source.len) {
        const c = source[lexer.index];
        if (c != '_' and (c < 'a' or c > 'z') and (c < 'A' or c > 'Z') and (c < '0' or c > '9')) {
            break;
        }
        lexer.index += 1;
    }
    const literal = source[start..lexer.index];
    return Token{ .kind = TokenKind.TK_ID, .literal = literal, .col = lexer.col, .line = lexer.line, .file = lexer.file };
}

fn lexNumber(source: []const u8, lexer: *Lexer) !Token {
    const start = lexer.index;
    while (lexer.index < source.len) {
        const c = source[lexer.index];
        if (c < '0' or c > '9') {
            break;
        }
        lexer.index += 1;
    }
    const literal = source[start..lexer.index];
    const value: i32 = try std.fmt.parseInt(i32, literal, 10);
    return Token{ .kind = TokenKind.TK_INT, .literal = literal, .value = value, .col = lexer.col, .line = lexer.line, .file = lexer.file };
}

fn lexWhitespace(source: []const u8, lexer: *Lexer) !Token {
    const start = lexer.index;
    while (lexer.index < source.len) {
        const c = source[lexer.index];
        if (c != ' ' and c != '\t' and c != '\n' and c != '\r') {
            break;
        }
        if (c == '\n') {
            lexer.line += 1;
            lexer.col = 0;
        } else {
            lexer.col += 1;
        }
        lexer.index += 1;
    }
    const literal = source[start..lexer.index];
    return Token{ .kind = TokenKind.TK_WS, .literal = literal, .col = lexer.col, .line = lexer.line, .file = lexer.file };
}

fn lexComment(source: []const u8, lexer: *Lexer) !Token {
    const start = lexer.index;
    while (lexer.index < source.len) {
        const c = source[lexer.index];
        if (c == '\n') {
            break;
        }
        lexer.index += 1;
        lexer.line += 1;
    }
    const literal = source[start..lexer.index];
    return Token{ .kind = TokenKind.TK_COMMENT, .literal = literal, .col = lexer.col, .line = lexer.line, .file = lexer.file };
}

// PARSER

const ASTNodeKind = enum { AK_TYPE, AK_ID, AK_PROGRAM, AK_TYPES, AK_TYPE_DECLARATION, AK_NESTED_DECL, AK_DECL, AK_DECLARATIONS, AK_DECLARATION, AK_ID_LIST, AK_FUNCTIONS, AK_FUNCTION, AK_PARAMETERS, AK_RETURN_TYPE, AK_STATEMENT, AK_BLOCK, AK_STATMENT_LIST, AK_ASSIGNMENT, AK_PRINT, AK_CONDITIONAL, AK_LOOP, AK_DELETE, AK_RET, AK_INVOCATION, AK_LVALUE, AK_EXPRESSION, AK_BOOLTERM, AK_EQTERM, AK_RELTERM, AK_SIMPLE, AK_TERM, AK_UNARY, AK_SELECTOR, AK_FACTOR, AK_ARGUMENTS };

const TypeKind = enum {
    TYK_INT,
    TYK_BOOL,
    TYK_VOID,
    TYK_STRUCT,
};

const ASTNode = struct {
    kind: ASTNodeKind,
    token: Token,
    type: TypeKind,
    children: []ASTNode,
    parent: *?ASTNode,
};

const Parser = struct {
    index: usize,
    tokens: []Token,
};

fn parse(tokens: []Token) !ASTNode {
    var parser = Parser{ .index = 0, .tokens = tokens };
    return parseProgram(&parser);
}

pub fn main() void {
    const source = "123 abc # comment\n";

    const tokens = lex(source, "");
    std.debug.print("source: {s}\n", .{source});
    std.debug.print("tokens: {any}\n", .{tokens});
}
