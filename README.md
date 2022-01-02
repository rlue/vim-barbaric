⌨️  Barbaric
==========

**vim + non-Latin input = pain.** _Barbaric_ is the cure.

![](https://raw.githubusercontent.com/rlue/i/master/vim-barbaric/demo.gif)

### Why?

Normal mode mappings (_e.g.,_ `h` / `j` / `k` / `l`) are all 8-bit ASCII characters. That means that when you want to work on a file in Russian (or Greek or Chinese), you’ve got to switch back to English (or Spanish or German) every time you leave Insert mode.

_Barbaric_ detects which input method is active when you first launch vim, then again any time you leave Input mode, and switches between them for you automatically.

### No, I mean why ‘Barbaric’?

From [Wikipedia](https://en.wikipedia.org/w/index.php?title=Barbarian&oldid=792816841) (emphasis mine):

> The Greeks used the term _barbarian_ for all non-Greek-speaking peoples,
> including the Egyptians, Persians, Medes and Phoenicians, emphasizing their
> otherness, because the language they spoke sounded to Greeks like gibberish
> represented by the sounds “bar bar bar”....
> 
> The Romans adapted the term **to refer to anything non-Roman**.

Vim doesn’t play nicely with non-Latin scripts; _i.e.,_ input languages of non-Roman origin. _Ipso facto,_ this is a plugin for barbarians.

### Supported IMEs

* macOS (requires [xkbswitch-macosx](https://github.com/xiehuc/xkbswitch-macosx))

  ```sh
  # Install via:
  $ curl -L -o /usr/local/bin/xkbswitch https://github.com/xiehuc/xkbswitch-macosx/releases/download/v0.1.0/xkbswitch
  ```

* fcitx
* ibus
* [xkb-switch](https://github.com/grwlf/xkb-switch)

If you need support for another IME or input system, consider:

* built-in support for X11 and MS-Windows IMEs (`:help mbyte-XIM` / `:help mbyte-IME`),
* built-in multi-byte keymaps (`:help mbyte-keymap` / explained [here](https://github.com/rlue/vim-barbaric/issues/2#issuecomment-344625562)), or
* [vim-xkbswitch](https://github.com/lyokha/vim-xkbswitch).

Installation
------------

There are lots of vim plugin managers out there. I like [vim-plug](https://github.com/junegunn/vim-plug).

Usage
-----

_Barbaric_ should work out of the box provided that whenever you launch vim, the active input method is the one you want to use in Normal mode. If that’s not the case, be sure to set the first option in the [configuration section](#configuration) below.

#### Known bugs

On macOS, in certain input methods (notably Chinese and Korean), switching windows away from vim and back can cause xkbswitch to malfunction. The problem is described [here](https://github.com/myshov/xkbswitch-macosx/issues/5).

Configuration
-------------

_Barbaric_ does its best to work out of the box with zero configuration.
To change its default behavior, modify the lines below and add them to your `.vimrc`. 

```viml
" The IME to invoke for managing input languages (macos, fcitx, ibus, xkb-switch)
let g:barbaric_ime = 'fcitx'

" The input method for Normal mode (as defined by `xkbswitch -g`, `ibus engine`, or `xkb-switch -p`)
let g:barbaric_default = 0

" The scope where alternate input methods persist (buffer, window, tab, global)
let g:barbaric_scope = 'buffer'

" Forget alternate input method after n seconds in Normal mode (disabled by default)
" Useful if you only need IM persistence for short bursts of active work.
let g:barbaric_timeout = -1

" The fcitx-remote binary (to distinguish between fcitx and fcitx5)
let g:barbaric_fcitx_cmd = 'fcitx5-remote'

" The xkb-switch library path (for Linux xkb-switch users ONLY)
let g:barbaric_libxkbswitch = $HOME . '/.local/lib/libxkbswitch.so'
```

Troubleshooting
---------------

* Some users have reported latency between leaving insert mode and the automatic switching of input methods ([#9](https://github.com/rlue/vim-barbaric/issues/9), [#15](https://github.com/rlue/vim-barbaric/issues/15), and [this comment](https://github.com/rlue/vim-barbaric/commit/e3c29ed5a45fa9da72313594a0c5ed89e2293b51#commitcomment-39779599)). If you experience this problem, try this:

  ```viml
  " .vimrc
  
  set ttimeoutlen=0
  ```

License
-------

The MIT License (MIT)

Copyright © 2017 Ryan Lue
