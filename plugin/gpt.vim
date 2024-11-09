if !exists('g:simp_buffer_prefix')
	let g:simp_buffer_prefix = 'Cable'
endif
if !exists('g:simp_tail')
	let g:simp_tail = 0
endif

fun! s:new_buffer() abort
	let g:simp_tail += 1
	let name = g:simp_buffer_prefix . g:simp_tail
	let buf = bufnr(name, 1)
	call setbufvar(buf, '&filetype', 'simp')
	call setbufvar(buf, '&buftype', 'nofile')
	call setbufvar(buf, '&bufhidden', 'hide')
	call setbufvar(buf, '&swapfile', 0)
	call setbufvar(buf, '&buflisted', 1)
	" open scratch_buf in the current window
	execute 'buffer' buf
endfun

fun! s:fzf_reveal_buffer(l)
	let keys = split(a:l, ':\t')
	exec 'buf' keys[0]
	exec keys[1]
	normal! ^zz
endfun

fun! s:fzf_chat_lines()
	let res = []
	for b in filter(range(1, bufnr('$')), 'buflisted(v:val) && bufname(v:val) =~ "^' . g:simp_buffer_prefix . '"')
		call extend(res, map(getbufline(b,0,"$"), 'b . ":\t" . (v:key + 1) . ":\t" . v:val '))
	endfor
	return res
endfun

fun! s:errcheck(job, data)
	if !empty(a:data)
		echohl ErrorMsg
		echomsg a:data
		echohl None
		sleep 3000
	endif
endfun

fun! simp#scratch(...) abort
	let tpl = get(g:, 'simp_default_register', '')
	if a:0 > 0
		let tpl = a:1
	endif
	call s:new_buffer()
	if tpl == ''
		" bring into insert position
		call feedkeys('i')
	else
		" insert the prompt template and bring to insert position
		call feedkeys('V"' . tpl . 'pGi')
	endif
endfun

fun! simp#instant() abort
	let model = get(g:, 'simp_default_model', 'gpt-4o')
	let opts = get(g:, 'simp_default_opts', '')
	call simp#job(model, opts)
endfun

fun! simp#dialog() abort
	let def_model = get(g:, 'simp_default_dialog_model', 'gpt-4o')
	let def_opts = get(g:, 'simp_default_dialog_opts', '0.5 1024')
	let model = input('model: ', def_model)
	let opts = input('[temperature max_length top_p fpen ppen]: ', def_opts)
	redraw
	call simp#job(model, opts)
endfun

fun! simp#job(model, opts) abort
	let command = &shell . ' -c "simp -vim ' . a:model . ' ' . a:opts . '"'
	let job_options = {
			\ 'noblock': 1,
			\ 'in_io': 'buffer',
			\ 'in_buf': bufnr('%'),
			\ 'in_top': 1,
			\ 'in_bot': line('$'),
			\ 'out_io': 'buffer',
			\ 'out_buf': bufnr('%'),
			\ 'err_io': 'pipe',
			\ 'err_cb': function('s:errcheck')
			\ }
	let job_id = job_start(command, job_options)
	echomsg 'simping: ' . a:model . '...'
endfun

fun! simp#history()
	call fzf#vim#grep('rg --column --line-number --no-heading --color=always --smart-case "" ' . $OPENAI_LOG_DIR, 1, fzf#vim#with_preview())
endfun

command! -nargs=? Simp call simp#scratch(<f-args>)
command! SimpDefault call simp#instant()
command! SimpDialog call simp#dialog()
command! SimpBuffers call fzf#run({
			\   'source':  <sid>fzf_chat_lines(),
			\   'sink':    function('<sid>fzf_reveal_buffer'),
			\})
command! SimpHistory call simp#history()
