" File: vim-inclement -- Great stuff for includes

function! inclement#ft#lua#init() abort
    " Extension is not used in require statements.
    let b:inclement_is_extension_relevant = 0
    let b:inclement_header_extensions = ["lua"]

    let b:inclement_find_import_re = '\v\C^.*<require>'
endf


function! inclement#ft#lua#GetExistingImportRegex(imported_file) abort
    return '\v\C^.*<require>[^"]*"(.*[.\/\\])?'. a:imported_file .'"'
endf


function! inclement#ft#lua#GetPrefix(tag_dict) abort
    if a:tag_dict["kind"] == "v"
        return "local ". a:tag_dict["name"] ." = "
    else
        return ""
    endif
endf

function! inclement#ft#lua#ConvertFilepathToImportPath(path) abort
    " Import folders containing init.lua and not that file.
    let p = substitute(a:path, '/init$', '', '')
    return substitute(p, '\V/', '.', 'g')
endf

function! inclement#ft#lua#GetImport(tag_dict) abort
    return inclement#ft#lua#GetPrefix(a:tag_dict). 'require '
endf
