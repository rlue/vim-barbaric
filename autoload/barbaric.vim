" GUARD CLAUSES ================================================================
" Prevent double-sourcing
execute exists('g:loaded_barbaric') ? 'finish' : 'let g:loaded_barbaric = 1'

" Check dependencies
call system('type xkbswitch') | if v:shell_error | finish | endif

" PUBLIC FUNCTIONS =============================================================
function! barbaric#switch(next_mode)
  if a:next_mode == 'normal'
    call s:record_current_im()
    call s:switch_to_im(g:barbaric_default)
    call s:set_timeout()
  elseif a:next_mode == 'insert'
    call s:check_timeout()
    if !exists(s:current_im()) | return | endif
    call s:switch_to_im(eval(s:current_im()))
  endif
endfunction

" HELPER FUNCTIONS =============================================================
" Scope ------------------------------------------------------------------------
function! s:scope_marker()
  let l:scope = s:current_scope()
  if l:scope == 'g'
    return
  elseif l:scope == 't'
    return tabpagenr()
  elseif l:scope == 'w'
    return win_getid()
  elseif l:scope == 'b'
    return bufnr('%')
  endif
endfunction

function! s:current_scope()
  return strcharpart(g:barbaric_scope, 0, 1)
endfunction

" Input method -----------------------------------------------------------------
function! s:current_im()
  return s:current_scope() . ':barbaric_current'
endfunction

function! s:record_current_im()
  execute "let " . s:current_im() . " = system('xkbswitch -g')"
  if eval(s:current_im()) == g:barbaric_default
    execute 'silent! unlet ' . s:current_im()
  endif
endfunction

function! s:switch_to_im(target)
  call system('xkbswitch -s ' . a:target)
endfunction

" Timeout ----------------------------------------------------------------------
function! s:set_timeout()
  if g:barbaric_timeout < 0 | return | endif

  let s:timeout = { 'scope': s:scope_marker(), 'begin': localtime() }
endfunction

function! s:check_timeout()
  if g:barbaric_timeout < 0 | return | endif
  if !exists('s:timeout') || (s:scope_marker() != get(s:timeout, 'scope'))
    return
  endif

  if (localtime() - get(s:timeout, 'begin')) > g:barbaric_timeout
    execute 'silent! unlet ' . s:current_im()
  endif
endfunction
