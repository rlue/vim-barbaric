if executable('xkbswitch')
  " The input method for Normal mode (as defined by `xkbswitch -g`)
  if !exists('g:barbaric_default')
    let g:barbaric_default = system('xkbswitch -g')
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
    autocmd FocusGained * call barbaric#switch('focus')
    autocmd FocusLost   * call barbaric#switch('unfocus')
    autocmd VimLeave    * call barbaric#switch('unfocus')
  augroup END
endif
