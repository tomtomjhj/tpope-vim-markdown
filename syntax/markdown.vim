" Vim syntax file
" Language:     Markdown
" Maintainer:   Tim Pope <https://github.com/tpope/vim-markdown>
" Filenames:    *.markdown
" Last Change:  2020 Jan 14

if exists("b:current_syntax")
  finish
endif

if !exists('main_syntax')
  let main_syntax = 'markdown'
endif

if has('folding')
  let s:foldmethod = &l:foldmethod
  let s:foldtext = &l:foldtext
endif
let s:iskeyword = &l:iskeyword

runtime! syntax/html.vim
unlet! b:current_syntax

if !exists('g:markdown_fenced_languages')
  let g:markdown_fenced_languages = []
endif
let s:done_include = {}
for s:ft in map(copy(g:markdown_fenced_languages),'matchstr(v:val,"[^=]*$")')
  if has_key(s:done_include, s:ft)
    continue
  endif
  syn case match
  exe 'syn include @markdownHighlight_'.s:ft.' syntax/'.s:ft.'.vim'
  unlet! b:current_syntax
  let s:done_include[s:ft] = 1
endfor
unlet! s:ft
unlet! s:done_include

syn spell toplevel
if exists('s:foldmethod') && s:foldmethod !=# &l:foldmethod
  let &l:foldmethod = s:foldmethod
  unlet s:foldmethod
endif
if exists('s:foldtext') && s:foldtext !=# &l:foldtext
  let &l:foldtext = s:foldtext
  unlet s:foldtext
endif
if s:iskeyword !=# &l:iskeyword
  let &l:iskeyword = s:iskeyword
endif
unlet s:iskeyword

if !exists('g:markdown_minlines')
  let g:markdown_minlines = 50
endif
execute 'syn sync minlines=' . g:markdown_minlines
syn sync maxlines=500
syn sync linebreaks=1
syn case ignore

syn match markdownValid '[<>]\c[a-z/$!]\@!' transparent contains=NONE
syn match markdownValid '&\%(#\=\w*;\)\@!' transparent contains=NONE

syn match markdownLineStart "^[<@]\@!" nextgroup=@markdownBlock,htmlSpecialChar

syn cluster markdownBlock contains=markdownH1,markdownH2,markdownH3,markdownH4,markdownH5,markdownH6,markdownBlockquote,markdownListMarker,markdownOrderedListMarker,markdownCodeBlock,markdownRule
syn cluster markdownInline contains=markdownLineBreak,markdownLinkText,markdownItalic,markdownBold,markdownCode,markdownEscape,@htmlTop,markdownValid

syn match markdownH1 "^.\+\n=\+$" contained contains=@markdownInline,markdownHeadingRule,markdownAutomaticLink
syn match markdownH2 "^.\+\n-\+$" contained contains=@markdownInline,markdownHeadingRule,markdownAutomaticLink

syn match markdownHeadingRule "^[=-]\+$" contained

syn region markdownH1 matchgroup=markdownH1Delimiter start=" \{,3}#\s"      end="#*\s*$" keepend oneline contains=@markdownInline,markdownAutomaticLink contained
syn region markdownH2 matchgroup=markdownH2Delimiter start=" \{,3}##\s"     end="#*\s*$" keepend oneline contains=@markdownInline,markdownAutomaticLink contained
syn region markdownH3 matchgroup=markdownH3Delimiter start=" \{,3}###\s"    end="#*\s*$" keepend oneline contains=@markdownInline,markdownAutomaticLink contained
syn region markdownH4 matchgroup=markdownH4Delimiter start=" \{,3}####\s"   end="#*\s*$" keepend oneline contains=@markdownInline,markdownAutomaticLink contained
syn region markdownH5 matchgroup=markdownH5Delimiter start=" \{,3}#####\s"  end="#*\s*$" keepend oneline contains=@markdownInline,markdownAutomaticLink contained
syn region markdownH6 matchgroup=markdownH6Delimiter start=" \{,3}######\s" end="#*\s*$" keepend oneline contains=@markdownInline,markdownAutomaticLink contained

syn match markdownBlockquote ">\%(\s\|$\)" contained nextgroup=@markdownBlock

" TODO: real nesting
syn match markdownListMarker "\s*[-*+]\%(\s\+\S\)\@=" contained
syn match markdownOrderedListMarker "\s*\<\d\+\.\%(\s\+\S\)\@=" contained

syn match markdownRule "\* *\* *\*[ *]*$" contained
syn match markdownRule "- *- *-[ -]*$" contained

syn match markdownLineBreak " \{2,\}$"

syn region markdownIdDeclaration matchgroup=markdownLinkDelimiter start="^ \{0,3\}!\=\[" end="\]:" oneline keepend nextgroup=markdownUrl skipwhite
syn match markdownUrl "\S\+" nextgroup=markdownUrlTitle skipwhite contained
syn region markdownUrl matchgroup=markdownUrlDelimiter start="<" end=">" oneline keepend nextgroup=markdownUrlTitle skipwhite contained
syn region markdownUrlTitle matchgroup=markdownUrlTitleDelimiter start=+"+ end=+"+ keepend contained
syn region markdownUrlTitle matchgroup=markdownUrlTitleDelimiter start=+'+ end=+'+ keepend contained
syn region markdownUrlTitle matchgroup=markdownUrlTitleDelimiter start=+(+ end=+)+ keepend contained

syn region markdownLinkText matchgroup=markdownLinkTextDelimiter start="!\=\[\%(\_[^][]*\%(\[\_[^][]*\]\_[^][]*\)*]\%( \=[[(]\)\)\@=" end="\]\%( \=[[(]\)\@=" nextgroup=markdownLink,markdownId skipwhite contains=@markdownInline,markdownLineStart
syn region markdownLink matchgroup=markdownLinkDelimiter start="(" end=")" contains=markdownUrl keepend contained
syn region markdownId matchgroup=markdownIdDelimiter start="\[" end="\]" keepend contained
syn region markdownAutomaticLink matchgroup=markdownUrlDelimiter start="<\%(\w\+:\|[[:alnum:]_+-]\+@\)\@=" end=">" keepend oneline

let s:concealends = ''
if has('conceal') && get(g:, 'markdown_syntax_conceal', 1) == 1
  let s:concealends = ' concealends'
endif
exe 'syn region markdownItalic matchgroup=markdownItalicDelimiter start="\*\S\@=" end="\S\@<=\*\|^$" skip="\\\*" contains=markdownLineStart,@Spell' . s:concealends
exe 'syn region markdownItalic matchgroup=markdownItalicDelimiter start="\w\@<!_\S\@=" end="\S\@<=_\w\@!\|^$" skip="\\_" contains=markdownLineStart,@Spell' . s:concealends
exe 'syn region markdownBold matchgroup=markdownBoldDelimiter start="\*\*\S\@=" end="\S\@<=\*\*\|^$" skip="\\\*" contains=markdownLineStart,markdownItalic,@Spell' . s:concealends
exe 'syn region markdownBold matchgroup=markdownBoldDelimiter start="\w\@<!__\S\@=" end="\S\@<=__\w\@!\|^$" skip="\\_" contains=markdownLineStart,markdownItalic,@Spell' . s:concealends
exe 'syn region markdownBoldItalic matchgroup=markdownBoldItalicDelimiter start="\*\*\*\S\@=" end="\S\@<=\*\*\*\|^$" skip="\\\*" contains=markdownLineStart,@Spell' . s:concealends
exe 'syn region markdownBoldItalic matchgroup=markdownBoldItalicDelimiter start="\w\@<!___\S\@=" end="\S\@<=___\w\@!\|^$" skip="\\_" contains=markdownLineStart,@Spell' . s:concealends
exe 'syn region markdownStrike matchgroup=markdownStrikeDelimiter start="\~\~\S\@=" end="\S\@<=\~\~\|^$" contains=markdownLineStart,@Spell' . s:concealends

syn region markdownCode matchgroup=markdownCodeDelimiter start="`" end="`\|^$" skip="``"
syn region markdownCode matchgroup=markdownCodeDelimiter start="``" end="``\|^$" skip="```"
syn region markdownCode matchgroup=markdownCodeDelimiter start="\$\S\@=" end="\S\@<=\$\|^$" skip="\\\$"
syn region markdownCode matchgroup=markdownCodeDelimiter start="\$\$" end="\$\$\|^$" skip="\\\$"
syn region markdownCodeBlock matchgroup=markdownCodeDelimiter start="\z(`\{3,\}\).*$" end="\z1\ze\s*$"
syn region markdownCodeBlock matchgroup=markdownCodeDelimiter start="\z(\~\{3,\}\).*$" end="\z1\ze\s*$"

syn match markdownFootnote "\[^[^\]]\+\]"
syn match markdownFootnoteDefinition "^\[^[^\]]\+\]:"

let s:done_include = {}
for s:type in g:markdown_fenced_languages
  if has_key(s:done_include, s:type)
    continue
  endif
  let s:name = matchstr(s:type,'[^=]*')
  let s:ft = matchstr(s:type,'[^=]*$')
  exe 'syn region markdownHighlight_'.s:ft.' matchgroup=markdownCodeDelimiter start="^\s*\z(`\{3,\}\)\s*\%({.\{-}\.\)\='.s:name.'}\=\S\@!.*$" end="^\s*\z1\ze\s*$" keepend contains=@markdownHighlight_'.s:ft . s:concealends
  exe 'syn region markdownHighlight_'.s:ft.' matchgroup=markdownCodeDelimiter start="^\s*\z(\~\{3,\}\)\s*\%({.\{-}\.\)\='.s:name.'}\=\S\@!.*$" end="^\s*\z1\ze\s*$" keepend contains=@markdownHighlight_'.s:ft . s:concealends
  let s:done_include[s:type] = 1
endfor
unlet! s:name s:ft
unlet! s:type
unlet! s:done_include

if get(b:, 'markdown_yaml_head', get(g:, 'markdown_yaml_head', main_syntax ==# 'markdown'))
  syn include @markdownYamlTop syntax/yaml.vim
  unlet! b:current_syntax
  syn region markdownYamlHead start="\%^---$" end="^\%(---\|\.\.\.\)\s*$" keepend contains=@markdownYamlTop,@Spell
endif

syn match markdownEscape "\\[][\\`$*_{}()<>#+.!-]"

hi def link markdownH1                    htmlH1
hi def link markdownH2                    htmlH2
hi def link markdownH3                    htmlH3
hi def link markdownH4                    htmlH4
hi def link markdownH5                    htmlH5
hi def link markdownH6                    htmlH6
hi def link markdownHeadingRule           markdownRule
hi def link markdownH1Delimiter           markdownHeadingDelimiter
hi def link markdownH2Delimiter           markdownHeadingDelimiter
hi def link markdownH3Delimiter           markdownHeadingDelimiter
hi def link markdownH4Delimiter           markdownHeadingDelimiter
hi def link markdownH5Delimiter           markdownHeadingDelimiter
hi def link markdownH6Delimiter           markdownHeadingDelimiter
hi def link markdownHeadingDelimiter      Delimiter
hi def link markdownOrderedListMarker     markdownListMarker
hi def link markdownListMarker            htmlTagName
hi def link markdownBlockquote            Comment
hi def link markdownRule                  PreProc

hi def link markdownFootnote              Typedef
hi def link markdownFootnoteDefinition    Typedef

hi def link markdownLinkText              htmlLink
hi def link markdownIdDeclaration         Typedef
hi def link markdownId                    Type
hi def link markdownAutomaticLink         markdownUrl
hi def link markdownUrl                   Float
hi def link markdownUrlTitle              String
hi def link markdownIdDelimiter           markdownLinkDelimiter
hi def link markdownUrlDelimiter          htmlTag
hi def link markdownUrlTitleDelimiter     Delimiter

hi def link markdownItalic                htmlItalic
hi def link markdownItalicDelimiter       markdownItalic
hi def link markdownBold                  htmlBold
hi def link markdownBoldDelimiter         markdownBold
hi def link markdownBoldItalic            htmlBoldItalic
hi def link markdownBoldItalicDelimiter   markdownBoldItalic
hi def link markdownStrike                htmlStrike
hi def link markdownStrikeDelimiter       markdownStrike

hi def link markdownCodeDelimiter         Delimiter

hi def link markdownEscape                Special

let b:current_syntax = "markdown"
if main_syntax ==# 'markdown'
  unlet main_syntax
endif

" vim:set sw=2:
