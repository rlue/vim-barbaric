if executable('xkbswitch')
  if !exists('g:barbaric_default_name')
    let g:barbaric_default_name = 'ABC'
  endif
  " The input method for Normal mode (as defined by `xkbswitch -g`)
  if !exists('g:barbaric_default')
    let g:barbaric_default = system('xkbswitch -g -e ' . g:barbaric_default_name)
  endif

  " The scope where alternate input methods persist (buffer, window, tab, global)
  if !exists('g:barbaric_scope')
    let g:barbaric_scope = 'buffer'
  endif

  " Forget alternate input method after n seconds in Normal mode (disabled by default)
  " Useful if you only need IM persistence for short bursts of active work.
  if !exists('g:barbaric_timeout')
    let g:barbaric_timeout = -1
  endif

  augroup barbaric
    autocmd!
    autocmd InsertEnter * call barbaric#switch('insert')
    autocmd InsertLeave * call barbaric#switch('normal')
    autocmd FocusLost   * call barbaric#switch('insert')
    autocmd FocusGained * call barbaric#switch('normal')
    autocmd VimLeave    * call barbaric#switch('insert')
    autocmd VimEnter    * call barbaric#switch('normal')
  augroup END
endif
