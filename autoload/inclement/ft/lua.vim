" File: vim-inclement -- Great stuff for includes

function! inclement#ft#lua#init()
    " Only exists to ensure this file is sourced.
endf

" Extension is not used in require statements.
let b:inclement_is_extension_relevant = 0
let b:inclement_header_extensions = ["lua"]

let b:inclement_find_import_re = '\v^.*<require>'

function! inclement#ft#lua#GetExistingImportRegex(imported_file)
    return '\v^.*<require>[^"]*"(.*[\/\\])?'. a:imported_file .'"'
endf


function! inclement#ft#lua#GetPrefix(tag_dict)
    if a:tag_dict["kind"] == "v"
        return "local ". a:tag_dict["name"] ." = "
    else
        return ""
    endif
endf

function! inclement#ft#lua#GetImport(tag_dict)
    return inclement#ft#lua#GetPrefix(a:tag_dict). 'require '
endf
