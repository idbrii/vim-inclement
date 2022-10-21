" File: vim-inclement -- Great stuff for includes

function! inclement#ft#cpp#init() abort
    let b:inclement_is_extension_relevant = 1
    let b:inclement_header_extensions = ["h", "hpp", "hh", "hxx"]

    let b:inclement_find_import_re = '\v\C^\s*#\s*include'
endf

function! inclement#ft#cpp#GetExistingImportRegex(imported_file) abort
    return '\v\C^\s*#\s*include\s*["<](.*[\/\\])?'. a:imported_file .'[">]'
endf

function! inclement#ft#cpp#ConvertFilepathToImportPath(path) abort
    " No fixup required.
    return a:path
endf

function! inclement#ft#cpp#FilterTagsForInclude(tags) abort
    return a:tags
endf

function! inclement#ft#cpp#GetImport(tag_dict) abort
    return '#include '
endf
