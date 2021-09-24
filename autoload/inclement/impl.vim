" File: vim-inclement -- Great stuff for includes
"
" TODO: Add forward declare
"       Jump to include on insert? -- need something since the includes are
"       big ugly paths since my tags aren't awesome.
"       Make filetype-specific options.
"

" Save compatibility options
let s:save_cpo = &cpo
set cpo&vim


function! s:has_filter(ft)
    let func = 'autoload/inclement/ft/'.a:ft.'.vim'
    return !empty(globpath(&runtimepath, func))
endfunction



" Function: FixGuard()
" Purpose: Update the header guards in the current buffer.
" Only supports C++
"
" Given club/barmanager.h, this produces the header guard BARMANAGER_H.
function! inclement#impl#FixGuard()
	let l:save_cursor = getcurpos()
	let l:path = expand("%") 

	" Compute the guard value
	let l:guard = substitute(l:path, '\([a-z]\)', '\u\1', 'g')
	let l:guard = substitute(l:guard, '\.', '_', 'g')
	let l:guard = substitute(l:guard, '^[^A-Z0-9_].*', '', 'g')

	" See if we can find the #ifndef/#define pair
	call cursor(1, 1)

	let l:guard_found = 0
	let l:gline = search('^\s*#ifndef\s\+[A-Za-z0-9_]\+\s*', 'nc')

	if l:gline > 0
		let l:oldguard = substitute(getline(l:gline), '^#\s*ifndef\s\+\([A-Za-z0-9_]\+\)\s*$', '\1', '')
		let l:dpat = '^#\s*define\s\+' . l:oldguard . '\s*$'
		let l:dline = search(l:dpat, 'Wn')

		if l:dline == l:gline + 1
			let l:guard_found = 1
			call setline(l:gline, '#ifndef ' . l:guard)
			call setline(l:dline, '#define ' . l:guard)
		endif
	endif

	if 0 == l:guard_found
		echo "Failed to find header guard"
	endif

	" Restore cursor position
	call setpos('.', l:save_cursor)
endfunction



" Purpose: Return the first header-based match for the specified tag
" expression.
"
" TODO: This could be improved to take a skip count so we could cycle between
" the headers.
function! s:GetHeaderForTag(tag_expr)
	let l:tags = taglist(a:tag_expr)
	for tag in l:tags
		" Convert to forward slashes.
		let l:fn = substitute(tag["filename"], "\\", "/", "g")
		let l:fnext = fnamemodify(l:fn, ":e")

		" Use header files straight away.
		if index(b:inclement_header_extensions, l:fnext) >= 0
			return [l:fn, tag]
		endif

	endfor
	return []
endfunction

" Purpose: Add a header path to the file.
function! s:InsertHeader(taginfo)
    " Save the current cursor so we can restore on error or completion
	let l:save_cursor = getcurpos()

    let l:path = a:taginfo[0]
    if !b:inclement_is_extension_relevant
        " Strip the extension.
        let l:path = fnamemodify(l:path, ':r')
    endif
    let src_root = get(b:, 'inclement_src_root', g:inclement_src_root)
    let l:path = substitute(l:path, '\V'.. src_root, '', '')

    " TODO: Error if filetype is not implemented.
    let l:import_cmd = inclement#ft#{&filetype}#GetImport(a:taginfo[1])

    " Only use the base name for higher likelihood of matches
    let l:filename = fnamemodify(l:path, ':t')

    " Check if including the current file
    let l:currentfile = expand('%:b')
    let l:samefile = match(l:currentfile, l:filename)
	if l:samefile == 0
        call setpos(".", l:save_cursor)
        echo 'include is current file'
        return
    endif

    " Check if include already exists
    let l:pattern = inclement#ft#{&filetype}#GetExistingImportRegex(l:filename)
	let l:iline = search(l:pattern)
	if l:iline > 0
        " Include already exists. Inform the user.

        call setpos(".", l:save_cursor)
        if ( g:inclement_use_preview )
            " Use the preview window to show the include
            set previewheight=1
            silent exec "pedit +" . l:iline
            echo 'include already present on line ' . l:iline
        else
            echo 'include already exists: ' . getline(l:iline)
        endif

        return
	endif

	if ( g:inclement_after_first_include )
		" Search forwards for the first include.
		normal! 0G
		let l:flags = ''
	else
		" Search backwards for the last include.
		normal! G
		let l:flags = 'b'
	endif
	" search() will return 0 if there are no matches, which will make the
	" append append on the first line in the file.
	let l:to_insert_after = search(b:inclement_find_import_re, l:flags)

    if ( g:inclement_use_preview )
        " Use the preview window to show the include
        " Use height=2 because we open preview before we put line (to
        " avoid unsaved error). So we show the line before and the include.
        set previewheight=2
        silent exec "pedit +" . l:to_insert_after
    endif


    let include_directories = get(b:, 'inclement_include_directories', g:inclement_include_directories)
    " include_directories is a bar-separated list of directory names
    let l:path = substitute(l:path, '^.*\v<('.. include_directories ..')>/', '', '')
    let l:path = inclement#ft#{&filetype}#ConvertFilepathToImportPath(l:path)
    " We only support quotes! See below.
	let l:text = l:import_cmd. '"' . l:path . '"'
	call append(l:to_insert_after, l:text)
    " We inserted a line, so change the cursor position
    let l:save_cursor[1] += 1

    " Get in position to fix the include and auto trim some directories.
    " We always insert quotes around include, so we can assume there's a quote
    " at the start.
    normal! jf"l
    if g:inclement_n_dir_to_trim > 0
        exec "normal! " . g:inclement_n_dir_to_trim . "df/"
    endif
    " HACK: To allow C# to strip entire path, introduce a buffer-local max
    " element. This doesn't make much sense when not using files.
    let max_element_in_path = get(b:, 'inclement_max_element_in_path', g:inclement_max_element_in_path)
    if max_element_in_path > 0
		normal! $
        exec 'normal! ' . max_element_in_path . 'T/dT"'
    endif
    normal! 0f"l

    " TODO: to support C#, we need to remove requirement for quotes.
    " HACK: For now, do some fixup. Requires on vim-surround.
    if &filetype == 'cs'
        normal ca";
    endif

    " Set lastpos mark so you can easily jump back to coding with ``
    call setpos("'`", l:save_cursor)

    if !g:inclement_use_preview
        let l:save_cursor = [0, l:to_insert_after, 1, 0, 1]
        " else: We have the preview window, so main doesn't need to show include
    endif
    call setpos(".", l:save_cursor)
endfunction

function! inclement#impl#AddIncludeForTag_Impl(tag_expr)
    if !s:has_filter(&filetype)
      if get(g:, 'inclement_report_ft_error', 1)
        echoerr 'inclement does not yet support '. &filetype
      endif
      return
    endif
    call inclement#ft#{&filetype}#init()

	let l:header = s:GetHeaderForTag(a:tag_expr)

	if len(l:header) == 0
		echo "No header declaring '" . a:tag_expr . "' found in tags"
		return
	endif

	call s:InsertHeader(header)
endfunction


" Reset compat options
let &cpo = s:save_cpo
