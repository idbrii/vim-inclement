" File: vim-inclement -- Great stuff for includes
" Maintainer: David Briscoe (idbrii@gmail.com)
" Version: 0.4
" based on dice.vim by Andreas Fredriksson
"
" Functionality:
"   * Add the header/require for a tag
"   * Fix header guards
"

" Protect against multiple reloads
if exists("loaded_inclement")
	finish
endif
let loaded_inclement = 1


" Ensure our settings variables exist and set defaults

let s:default_show = 'jump'
if get(g:, 'inclement_use_preview', 0)
	let s:default_show = 'preview'
	echomsg "inclement_use_preview is deprecated. Use inclement_show_include = 'preview' instead."
end
let g:inclement_show_include = get(g:, 'inclement_show_include', s:default_show)
unlet s:default_show

let g:inclement_n_dir_to_trim = get(g:, 'inclement_n_dir_to_trim', 0)
let g:inclement_max_element_in_path = get(g:, 'inclement_max_element_in_path', 0)
let g:inclement_after_first_include = get(g:, 'inclement_after_first_include', 0)
let g:inclement_include_directories = get(g:, 'inclement_include_directories', '')
" When you setup your project, set this to the root of your source folder so
" we can strip this path from any includes.
let g:inclement_src_root = get(g:, 'inclement_src_root', '')


" Save compatibility options
let s:save_cpo = &cpo
set cpo&vim

noremap <unique> <script> <Plug>InclementAddIncludeForTag <SID>AddIncludeForTag
noremap <unique> <script> <Plug>InclementFixHeaderGuard <SID>FixHeaderGuard

noremap <SID>AddIncludeForTag :call inclement#impl#AddIncludeForTag_Impl(expand("<cword>"))<CR>
noremap <SID>FixHeaderGuard :call inclement#impl#FixGuard()<CR>

if (! exists('no_plugin_maps') || ! no_plugin_maps) &&
      \ (! exists('no_inclement_maps') || ! no_inclement_maps)

    if !hasmapto('<Plug>InclementAddIncludeForTag')
        map <unique> <Leader>hi <Plug>InclementAddIncludeForTag
    endif

    if !hasmapto('<Plug>InclementFixHeaderGuard')
        map <unique> <Leader>hg <Plug>InclementFixHeaderGuard
    endif
endif

if (! exists('no_plugin_menus') || ! no_plugin_menus) &&
      \ (! exists('no_inclement_menus') || ! no_inclement_menus)

    noremenu <script> Inclement.Add\ Include\ for\ Symbol <SID>AddIncludeForTag
    noremenu <script> Inclement.Fix\ Header\ Guard <SID>FixHeaderGuard
endif

" Reset compat options
let &cpo = s:save_cpo
