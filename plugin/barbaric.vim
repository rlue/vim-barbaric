call system('type xkbswitch') | if !v:shell_error
  if !exists('g:barbaric_default')
    let g:barbaric_default = system('xkbswitch -g')
  endif

  if !exists('g:barbaric_scope')
    let g:barbaric_scope = 'buffer'
  endif

  if !exists('g:barbaric_timeout')
    let g:barbaric_timeout = -1
  endif

  augroup barbaric
    autocmd!
    autocmd InsertEnter * call barbaric#switch('insert')
    autocmd InsertLeave * call barbaric#switch('normal')
  augroup END
endif
