" PREFLIGHT ====================================================================

" What IME are we using? -------------------------------------------------------
if !exists('g:barbaric_libxkbswitch')
  if exists('g:XkbSwitchLib')
    let g:barbaric_libxkbswitch = g:XkbSwitchLib
  elseif filereadable('/usr/lib/libxkbswitch.so')
    let g:barbaric_libxkbswitch = '/usr/lib/libxkbswitch.so'
  elseif filereadable('/lib/libxkbswitch.so')
    let g:barbaric_libxkbswitch = '/lib/libxkbswitch.so'
  endif
endif

if !exists('g:barbaric_ime')
  let g:barbaric_uname = substitute(system('uname'), '\n', '', '')

  if g:barbaric_uname == 'Darwin' && executable('xkbswitch')
    let g:barbaric_ime = 'macos'
  elseif exists('g:barbaric_libxkbswitch')
    let g:barbaric_ime = 'xkb-switch'
  elseif executable('fcitx-remote') && system('fcitx-remote') > 0
    let g:barbaric_ime = 'fcitx'
  elseif executable('ibus')
    let g:barbaric_ime = 'ibus'
  else
    finish
  endif
endif

" What language should Normal mode revert to? ----------------------------------
" (as defined, e.g., by `xkbswitch -g`, `ibus engine`, or `xkb-switch -p`)
if !exists('g:barbaric_default')
  if g:barbaric_ime == 'fcitx'
    let g:barbaric_default = '-c'
  else
    let g:barbaric_default = barbaric#get_im()
  endif
endif

" Once an input language has been identified, where else should we use it? -----
" (choose from 'buffer', 'window', 'tab', 'global')
if !exists('g:barbaric_scope')
  let g:barbaric_scope = 'buffer'
endif

" How long until Barbaric automatically resets/forgets the input language? -----
" (disabled by default; useful for limiting IM persistence to short bursts of active work)
if !exists('g:barbaric_timeout')
  let g:barbaric_timeout = -1
endif

" FIRE IT UP ===================================================================
augroup barbaric
  autocmd!
  autocmd InsertEnter * call barbaric#switch('insert')
  autocmd InsertLeave * call barbaric#switch('normal')
  autocmd FocusGained * call barbaric#switch('focus')
  autocmd FocusLost   * call barbaric#switch('unfocus')
  autocmd VimLeave    * call barbaric#switch('unfocus')
  autocmd VimEnter    * call barbaric#switch('normal')
augroup END
