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

if !exists('g:barbaric_fcitx_cmd')
  if executable('fcitx-remote')
    let g:barbaric_fcitx_cmd = 'fcitx-remote'
  elseif executable('fcitx5-remote')
    let g:barbaric_fcitx_cmd = 'fcitx5-remote'
  endif
endif

if !exists('g:barbaric_ime')
  silent let g:barbaric_uname = substitute(system('uname'), '\n', '', '')

  silent if executable('macism')
    let g:barbaric_ime = 'macism'
  elseif g:barbaric_uname == 'Darwin' && executable('xkbswitch')
    let g:barbaric_ime = 'mac-xkbswitch'
  elseif exists('g:barbaric_libxkbswitch')
    let g:barbaric_ime = 'xkb-switch'
  elseif exists('g:barbaric_fcitx_cmd') && system(g:barbaric_fcitx_cmd) > 0
    let g:barbaric_ime = 'fcitx'
  elseif executable('ibus')
    let g:barbaric_ime = 'ibus'
  else
    finish
  endif
endif

" What language should Normal mode revert to? ----------------------------------
" (as defined, e.g., by `xkbswitch -g`, `ibus engine`, or `xkb-switch -p`)
let s:current_im = barbaric#get_im()

if !exists('g:barbaric_default')
  if g:barbaric_ime == 'fcitx'
    let g:barbaric_default = '-c'
  else
    " WARN: will be wrong if user launches vim in non-Latin IM
    let g:barbaric_default = s:current_im
  endif
elseif (g:barbaric_default != s:current_im)
  let s:launched_in_nonlatin_im = 1
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

  " see https://github.com/rlue/vim-barbaric/issues/26
  if exists('s:launched_in_nonlatin_im') && (has('nvim') || !exists('v:versionlong') || (v:versionlong <= 9011914))
    autocmd VimEnter * call barbaric#switch('normal')
  endif
augroup END
