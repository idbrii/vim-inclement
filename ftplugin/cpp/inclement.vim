" File: vim-inclement -- Great stuff for includes
" Maintainer: David Briscoe (idbrii@gmail.com)
" Version: 0.2
" based on dice.vim by Andreas Fredriksson
"
" Functionality:
"   * Fix header guards
"   * Add the header for a tag
"
" TODO: Add forward declare
"       Jump to include on insert? -- need something since the includes are
"       big ugly paths since my tags aren't awesome.
"

" Protect against multiple reloads
if exists("loaded_inclement")
	finish
endif
let loaded_inclement = 1


" Ensure our settings variables exist and set defaults
if !exists('g:inclement_use_preview')
    let g:inclement_use_preview = 0
end
if !exists('g:inclement_n_dir_to_trim')
    let g:inclement_n_dir_to_trim = 0
end
if !exists('g:inclement_max_element_in_path')
    let g:inclement_max_element_in_path = 0
end
if !exists('g:inclement_after_first_include')
    let g:inclement_after_first_include = 0
end


" Save compatibility options
let s:save_cpo = &cpo
set cpo&vim

noremap <unique> <script> <Plug>CppAddIncludeForTag <SID>AddIncludeForTag
noremap <unique> <script> <Plug>CppFixHeaderGuard <SID>FixHeaderGuard

noremap <SID>AddIncludeForTag :call inclement#impl#AddIncludeForTag_Impl(expand("<cword>"))<CR>
noremap <SID>FixHeaderGuard :call inclement#impl#FixGuard()<CR>

if (! exists('no_plugin_maps') || ! no_plugin_maps) &&
      \ (! exists('no_inclement_maps') || ! no_inclement_maps)

    if !hasmapto('<Plug>CppAddIncludeForTag')
        map <unique> <Leader>hi <Plug>CppAddIncludeForTag
    endif

    if !hasmapto('<Plug>CppFixHeaderGuard')
        map <unique> <Leader>hg <Plug>CppFixHeaderGuard
    endif
endif

if (! exists('no_plugin_menus') || ! no_plugin_menus) &&
      \ (! exists('no_inclement_menus') || ! no_inclement_menus)

    noremenu <script> Cpp.Add\ Include\ for\ Symbol <SID>AddIncludeForTag
    noremenu <script> Cpp.Fix\ Header\ Guard <SID>FixHeaderGuard
endif

" Reset compat options
let &cpo = s:save_cpo
