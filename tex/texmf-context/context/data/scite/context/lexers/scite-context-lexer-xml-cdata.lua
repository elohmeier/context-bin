local info = {
    version   = 1.002,
    comment   = "scintilla lpeg lexer for xml cdata",
    author    = "Hans Hagen, PRAGMA-ADE, Hasselt NL",
    copyright = "PRAGMA ADE / ConTeXt Development Team",
    license   = "see context related readme files",
}

local P = lpeg.P

local lexers        = require("scite-context-lexer")

local patterns      = lexers.patterns
local token         = lexers.token

local xmlcdatalexer = lexers.new("xml-cdata","scite-context-lexer-xml-cdata")

local space         = patterns.space
local nospace       = 1 - space - P("]]>")

local t_spaces      = token("whitespace", space^1)
local t_cdata       = token("comment",    nospace^1)

xmlcdatalexer.rules = {
    { "whitespace", t_spaces },
    { "cdata",      t_cdata  },
}

return xmlcdatalexer
