" Vim filetype plugin
" Language:     Markdown
" Maintainer:   Tim Pope <https://github.com/tpope/vim-markdown>
" Last Change:  2019 Dec 05

if exists("b:did_ftplugin")
  finish
endif

runtime! ftplugin/html.vim ftplugin/html_*.vim ftplugin/html/*.vim

setlocal comments=fb:*,fb:-,fb:+,n:> commentstring=<!--%s-->
setlocal formatoptions+=tcqln formatoptions-=r formatoptions-=o
setlocal formatlistpat=^\\s*\\d\\+\\.\\s\\+\\\|^\\s*[-*+]\\s\\+\\\|^\\[^\\ze[^\\]]\\+\\]:\\&^.\\{4\\}

if exists('b:undo_ftplugin')
  let b:undo_ftplugin .= "|setl cms< com< fo< flp< et< ts< sts< sw<"
else
  let b:undo_ftplugin = "setl cms< com< fo< flp< et< ts< sts< sw<"
endif

if get(g:, 'markdown_recommended_style', 1)
  setlocal expandtab tabstop=4 softtabstop=4 shiftwidth=4
endif

if !exists("g:no_plugin_maps") && !exists("g:no_markdown_maps")
  nnoremap <silent><buffer> [[ :<C-U>call search('\%(^#\{1,5\}\(\s\\|$\)\\|^\S.*\n^[=-]\+$\)', "bsW")<CR>
  nnoremap <silent><buffer> ]] :<C-U>call search('\%(^#\{1,5\}\(\s\\|$\)\\|^\S.*\n^[=-]\+$\)', "sW")<CR>
  xnoremap <silent><buffer> [[ :<C-U>exe "normal! gv"<Bar>call search('\%(^#\{1,5\}\(\s\\|$\)\\|^\S.*\n^[=-]\+$\)', "bsW")<CR>
  xnoremap <silent><buffer> ]] :<C-U>exe "normal! gv"<Bar>call search('\%(^#\{1,5\}\(\s\\|$\)\\|^\S.*\n^[=-]\+$\)', "sW")<CR>
  let b:undo_ftplugin .= '|sil! nunmap <buffer> [[|sil! nunmap <buffer> ]]|sil! xunmap <buffer> [[|sil! xunmap <buffer> ]]'
endif

function! s:IsCodeBlock(lnum) abort
  let synstack = synstack(a:lnum, 1)
  for i in synstack
    if synIDattr(i, 'name') =~# '^\%(markdown\%(Code\|Highlight\|Yaml\)\|htmlComment\)'
      return 1
    endif
  endfor
  return 0
endfunction

function! MarkdownFold() abort
  let line = getline(v:lnum)
  let hashes = matchstr(line, '^#\+\(\s\|$\)\@=')
  let is_code = -1
  if !empty(hashes)
    let is_code = s:IsCodeBlock(v:lnum)
    if !is_code
      return ">" . len(hashes)
    endif
  endif
  if !empty(line)
    let nextline = getline(v:lnum + 1)
    if nextline =~ '^=\+$'
      if is_code == -1
        let is_code = s:IsCodeBlock(v:lnum)
      endif
      if !is_code
        return ">1"
      endif
    endif
    if nextline =~ '^-\+$'
      if is_code == -1
        let is_code = s:IsCodeBlock(v:lnum)
      endif
      if !is_code
        return ">2"
      endif
    endif
  endif
  return "="
endfunction

function! s:HashIndent(lnum) abort
  let hash_header = matchstr(getline(a:lnum), '^#\{1,6}')
  if len(hash_header)
    return hash_header
  else
    let nextline = getline(a:lnum + 1)
    if nextline =~# '^=\+\s*$'
      return '#'
    elseif nextline =~# '^-\+\s*$'
      return '##'
    endif
  endif
endfunction

function! MarkdownFoldText() abort
  let hash_indent = s:HashIndent(v:foldstart)
  let title = substitute(getline(v:foldstart), '^#\+\s*', '', '')
  let foldsize = (v:foldend - v:foldstart + 1)
  let linecount = '['.foldsize.' lines]'
  return hash_indent.' '.title.' '.linecount
endfunction

if has("folding") && get(g:, "markdown_folding", 0)
  setlocal foldexpr=MarkdownFold()
  setlocal foldmethod=expr
  setlocal foldtext=MarkdownFoldText()
  let b:undo_ftplugin .= "|setl foldexpr< foldmethod< foldtext<"
endif

" vim:set sw=2:
