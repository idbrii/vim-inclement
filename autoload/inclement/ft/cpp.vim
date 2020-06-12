" File: vim-inclement -- Great stuff for includes

function! inclement#ft#cpp#init()
    let b:inclement_is_extension_relevant = 1
    let b:inclement_header_extensions = ["h", "hpp", "hh", "hxx"]

    let b:inclement_find_import_re = '^\s*#\s*include'
endf

function! inclement#ft#cpp#GetExistingImportRegex(imported_file)
    return '\v^\s*#\s*include\s*["<](.*[\/\\])?'. a:imported_file .'[">]'
endf

function! inclement#ft#cpp#ConvertFilepathToImportPath(path)
    " No fixup required.
    return a:path
endf

function! inclement#ft#cpp#GetImport(tag_dict)
    return '#include '
endf
