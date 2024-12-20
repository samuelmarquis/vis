-- nix LPEG lexer
-- written by Samuel Marquis

local lexer = lexer
local token, word_match = lexer.token, lexer.word_match
local P, S, B = lpeg.P, lpeg.S, lpeg.B

local lex = lexer.new(...)

lex:add_rule('keyword', lex:tag(lexer.KEYWORD, lex:word_match(lexer.KEYWORD)))

lex:set_word_list(lexer.KEYWORD, {
	'let', 'with', 'in', 'rec', 'inherit', 'assert',
	'if', 'then', 'else'
}

lexer.property['scintillua.comment'] = '#'

return lex
