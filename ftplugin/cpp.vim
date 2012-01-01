let s:save_cpo = &cpo
set cpo&vim

function! s:should_complete()
  if getline('.') =~ '\<#\s*\%(include\|import\)'
    return 0
  endif

  if col('.') == 1
    return 1
  endif

  for id in synstack(line('.'), col('.') - 1)
    if synIDattr(id, 'name') =~ '\CComment\|String\|Number'
      return 0
    endif
  endfor

  return 1
endfunction

function! s:launch_completion()
  let result = ''

  if s:should_complete()
    let result = "\<C-x>\<C-o>"
    if g:clang_auto_select != 2
      let result .= "\<C-p>"
    endif
    if g:clang_auto_select == 1
      let result .= "\<C-r>=(pumvisible() ? \"\\<Down>\" : '')\<CR>"
    endif
  endif

  return result
endfunction

function! s:complete_dot()
  if g:clang_complete_auto
    return '.' . s:launch_completion()
  endif

  return '.'
endfunction

function! s:complete_arrow()
  if !g:clang_complete_auto || s:get_cur_text() !~ '-$'
    return '>'
  endif

  return '>' . s:launch_completion()
endfunction

function! s:complete_colon()
  if !g:clang_complete_auto || s:get_cur_text() !~ ':$'
    return ':'
  endif

  return ':' . s:launch_completion()
endfunction

function! s:init_clang_complete()
  if exists('g:clang_complete_auto') && g:clang_complete_auto
    inoremap <expr> <buffer> . <SID>complete_dot()
    inoremap <expr> <buffer> > <SID>complete_arrow()
    inoremap <expr> <buffer> : <SID>complete_colon()
  endif
endfunction

function! s:get_cur_text()
  return matchstr(getline('.'),
        \ '^.*\%' . col('.') . 'c' . (mode() ==# 'i' ? '' : '.'))
endfunction

autocmd InsertEnter <buffer> call s:init_clang_complete()

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: sw=2 sts=2
