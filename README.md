# vim-simp
> This plugin depends on [simp][1] being installed and configured.

This plugin brings OpenAI streaming chat completion API to Vim scratch buffers, & registers. In particular, when running `:Simp [<reg>]` it opens a scratch buffer, if `g:simp_default_register` is specified, the buffer will be populated using said register. The scratch buffers created using `:Simp` are visible in the buffers list, simplifying navigation and allowing to search through them and employ tools like [fzf][3]. There's also [vim-markdown][4] support for code highligts in all `simp` buffers, including folding.

Please note: [simp][1] tool may be configured to specifically write down all previous conversations to separate files in a folder of your choosing. This means that you can use the `:SimpHistory` command provided by this plugin to do a fuzzy find (with preview) of all previous chats; meaning you can get back to any conversation you've had and carry on as you were!

Use `:SimpDefault` as a one-touch bind to quickly run completion with a model and options of your choice. For more fine control, you can use the `:SimpDialog` command allowing you to pick the model (3, 4) and enter arbitrary number of parameters (see [simp][1] for details) in a single `input()` prompt on the spot.

Most important of all, both [simp][1] and this plugin allow conversations:

<img src="https://i.imgur.com/jigt7XF.png" width="50%" height="50%"/>

Notice the tabulated guidemarks; also, the system text before the first prompt guidemark may be skipped.

Consider that if the guide marks are not provided, the contents of the whole buffer would be used as prompt, which may not be exactly what you're looking for. Using a dedicated register for the scratch template and the fact that [simp][1] appends the prompting `>>>` guide mark post-generation on its own, you may never have to put them in by hand, although various binds/abbreviations may be employed in that case.

```vim
Plug 'busthorne/vim-simp'

" defaults, not required but handy
let g:simp_buffer_prefix = 'Chat'
let g:simp_default_register = 'p'
let g:simp_default_model = '4o'
let g:simp_default_opts = ''
let g:simp_default_dialog_model = '4o'
let g:simp_default_dialog_opts = '0.7 256'
" https://github.com/tpope/vim-markdown
let g:markdown_fenced_languages = ['go', 'python', 'javascript']

" open a scratch containing default register in the current window
nnoremap ,, <Cmd>Simp<CR>
inoremap ,, <Esc>:Simp<CR>
augroup simp_binds
	au FileType simp nnoremap <buffer><silent> <Home> <Cmd>SimpDefault<CR>
	au FileType simp nnoremap <buffer><silent> <End> <Cmd>SimpDialog<CR>
	au FileType simp inoremap <buffer><silent> <Home> <Esc>:SimpDefault<CR>
	au FileType simp inoremap <buffer><silent> <End> <Esc>:SimpDialog<CR>
augroup END
```

You can bind either `:SimpDefault` or `:SimpDialog` to whatever keys you want but I'm personally following my Keychron lifehack that I've come up with previously for Copilot, as pgup/pgdown/home/end keys are easily accessible and don't require any special kind of binds.

![][2]


### License

MIT

[1]: https://github.com/busthorne/simp
[2]: https://i.redd.it/cuusrp3qgooa1.png
[3]: https://github.com/junegunn/fzf.vim
[4]: https://github.com/tpope/vim-markdown
