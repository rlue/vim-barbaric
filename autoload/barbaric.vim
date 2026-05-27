" GUARD CLAUSES ================================================================
" Prevent double-sourcing
execute exists('g:loaded_barbaric') ? 'finish' : 'let g:loaded_barbaric = 1'

" PUBLIC FUNCTIONS =============================================================
function! barbaric#switch(next_mode)
  if reg_executing() != '' | return | endif

  if a:next_mode == 'normal'
    let l:current_im = barbaric#get_im()

    if l:current_im != g:barbaric_default
      call s:stash_im(l:current_im)
      call s:set_im(g:barbaric_default) " restore Normal IM
      call s:set_timeout()
    else " reset state
      call s:drop_im()
    endif
  elseif a:next_mode == 'insert' && s:im_stashed()
    if s:timeout_elapsed()
      call s:drop_im()
    else
      call s:set_im(s:unstash_im()) " restore Insert IM
    endif
  endif
endfunction

" HELPER FUNCTIONS =============================================================
" Scope ------------------------------------------------------------------------
function! s:scope()
  let l:scope = strcharpart(g:barbaric_scope, 0, 1)

  if l:scope == 'g'
    return g:
  elseif l:scope == 't'
    return t:
  elseif l:scope == 'w'
    return w:
  elseif l:scope == 'b'
    return b:
  endif

  return {}
endfunction

function! s:scope_marker()
  let l:scope = s:scope()

  if l:scope is g:
    return
  elseif l:scope is t:
    return tabpagenr()
  elseif l:scope is w:
    return win_getid()
  elseif l:scope is b:
    return bufnr('%')
  endif
endfunction

" Input method -----------------------------------------------------------------
function! barbaric#get_im()
  if g:barbaric_ime == 'macism'
    silent return system('macism')
  elseif g:barbaric_ime == 'mac-xkbswitch'
    silent return system('xkbswitch -g')
  elseif g:barbaric_ime == 'xkb-switch'
    return libcall(g:barbaric_libxkbswitch, 'Xkb_Switch_getXkbLayout', '')
  elseif g:barbaric_ime == 'fcitx'
    silent return system(g:barbaric_fcitx_cmd) == 2 ? '-o' : '-c'
  elseif g:barbaric_ime == 'ibus'
    silent return system('ibus engine')
  endif
endfunction

function! s:set_im(im)
  if a:im == ''
    throw 'barbaric: s:set_im() called with empty argument'
  endif

  if g:barbaric_ime == 'macism'
    silent call system('macism ' . a:im)
  elseif g:barbaric_ime == 'mac-xkbswitch'
    silent call system('xkbswitch -s ' . a:im)
  elseif g:barbaric_ime == 'xkb-switch'
    call libcall(g:barbaric_libxkbswitch, 'Xkb_Switch_setXkbLayout', a:im)
  elseif g:barbaric_ime == 'fcitx'
    silent call system(g:barbaric_fcitx_cmd . ' ' . a:im)
  elseif g:barbaric_ime == 'ibus'
    silent call system('ibus engine ' . a:im)
  endif
endfunction

function! s:stash_im(im)
  let l:scope = s:scope()
  let l:scope.barbaric_current = a:im
endfunction

function! s:unstash_im()
  return get(s:scope(), 'barbaric_current', '')
endfunction

function! s:im_stashed()
  return has_key(s:scope(), 'barbaric_current')
endfunction

function! s:drop_im()
  if s:im_stashed()
    call remove(s:scope(), 'barbaric_current')
  endif
endfunction

" Timeout ----------------------------------------------------------------------
function! s:set_timeout()
  if g:barbaric_timeout < 0 | return | endif

  let s:timeout = { 'scope': s:scope_marker(), 'begin': localtime() }
endfunction

function! s:timeout_elapsed()
  if g:barbaric_timeout < 0 | return 0 | endif
  if !exists('s:timeout') || (get(s:timeout, 'scope') != s:scope_marker())
    return 0
  endif

  if (localtime() - get(s:timeout, 'begin')) > g:barbaric_timeout
    return 1
  endif
endfunction
