" GUARD CLAUSES ================================================================
" Prevent double-sourcing
execute exists('g:loaded_barbaric') ? 'finish' : 'let g:loaded_barbaric = 1'

" PUBLIC FUNCTIONS =============================================================
function! barbaric#switch(next_mode)
  if a:next_mode == 'normal'
    call s:record_im()
    call s:restore_normal_im()
    call s:set_timeout()
  elseif a:next_mode == 'insert'
    call s:check_timeout()
    call s:restore_insert_im()
  endif
endfunction

" HELPER FUNCTIONS =============================================================
" Scope ------------------------------------------------------------------------
function! s:scope_marker()
  let l:scope = s:scope()
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

function! s:scope()
  return strcharpart(g:barbaric_scope, 0, 1)
endfunction

" Input method -----------------------------------------------------------------
function! s:record_im()
  let l:im = barbaric#get_im()
  if l:im == g:barbaric_default
    execute 'silent! unlet ' . s:im_varname()
  else
    execute "silent! let " . s:im_varname() . " = '" . l:im . "'"
  endif
endfunction

function! barbaric#get_im()
  if g:barbaric_ime == 'macos'
    return system('xkbswitch -g')
  elseif g:barbaric_ime == 'xkb-switch'
    return libcall(g:barbaric_libxkbswitch, 'Xkb_Switch_getXkbLayout', '')
  elseif g:barbaric_ime == 'fcitx'
    return system(g:barbaric_fcitx_cmd) == 2 ? '-o' : '-c'
  elseif g:barbaric_ime == 'ibus'
    return system('ibus engine')
  endif
endfunction

function! s:restore_normal_im()
  call s:set_im(g:barbaric_default)
endfunction

function! s:restore_insert_im()
  if !exists(s:im_varname()) | return | endif
  call s:set_im(eval(s:im_varname()))
endfunction

function! s:set_im(im)
  if g:barbaric_ime == 'macos'
    silent call system('xkbswitch -s ' . a:im)
  elseif g:barbaric_ime == 'xkb-switch'
    call libcall(g:barbaric_libxkbswitch, 'Xkb_Switch_setXkbLayout', a:im)
  elseif g:barbaric_ime == 'fcitx'
    silent call system(g:barbaric_fcitx_cmd . ' ' . a:im)
  elseif g:barbaric_ime == 'ibus'
    silent call system('ibus engine ' . a:im)
  endif
endfunction

function! s:im_varname()
  return s:scope() . ':barbaric_current'
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
    execute 'silent! unlet ' . s:im_varname()
  endif
endfunction
