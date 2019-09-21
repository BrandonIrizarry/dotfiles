--[[
	Example lexer from the Textadept Quick Reference Guide.
As a minimum, you need to 

1. Require the lexer module;
2. Create a new lexer;
3. Return the new lexer.

For example, the following one-liner constitutes a complete, valid 
definition of ~/.textadept/lexers/foo.lua, the example "foo" lexer:

return require("lexer").new "foo"
]]

-- Basic definitions.
local lexer = require "lexer"

local token, word_match = lexer.token, lexer.word_match
local P, R, S = lpeg.P, lpeg.R, lpeg.S

-- Specify the lexer's name.
local lex = lexer.new "foo"

-- Whitespace.
local ws = token(lexer.WHITESPACE, lexer.space^1)
lex:add_rule("whitespace", ws)

-- Keywords.
local keyword = token(lexer.KEYWORD, word_match[[
	else for function if return while
]])
lex:add_rule("keyword", keyword)

-- Special.
local special = token("special", P("foo"))
lex:add_rule("special", special)
lex:add_style("special", lexer.STYLE_CONSTANT)

-- Identifiers.
local identifier = token(lexer.IDENTIFIER, lexer.word)
lex:add_rule("identifier", identifier)

-- Strings.
local string = token(lexer.STRING, lexer.delimited_range('"', true))
lex:add_rule("string", string)

-- Comments.
local comment = token(lexer.COMMENT, "#" * lexer.nonnewline^0)
lex:add_rule("comment", comment)

-- Numbers.
local number = token(lexer.NUMBER, lexer.float + lexer.integer)
lex:add_rule("number", number)

-- Operators.
local operator = token(lexer.OPERATOR, S("+-/*^<>=()[]{}"))
lex:add_rule("operator", operator)

-- Specify how the lexer folds code.
lex:add_fold_point(lexer.COMMENT, "#", lexer.fold_line_comments("#"))
lex:add_fold_point(lexer.OPERATOR, "{", "}")

return lex
