" File: vim-inclement -- Great stuff for includes

function! inclement#ft#cs#init() abort
    let b:inclement_is_extension_relevant = 0
    let b:inclement_header_extensions = ["cs"]
    " HACK: Strip entire path. Hope the filename matches the class name.
    " TODO: use tag_dict.name instead.
    let b:inclement_max_element_in_path = 1

    let b:inclement_find_import_re = '^\v\C\s*using\s'
endf

function! inclement#ft#cs#GetExistingImportRegex(imported_file) abort
    " Case-insensitive since we're using files to estimate namespaces
    return '\v\c^.*<using>\s+.*'. a:imported_file .';'
endf

function! inclement#ft#cs#ConvertFilepathToImportPath(path) abort
    " No fixup required. We stripped the entire path (C# module paths don't
    " necessarily have any relationship to their file paths).
    return a:path
endf

function! inclement#ft#cs#FilterTagsForInclude(tags) abort
    return a:tags
endf

function! inclement#ft#cs#GetImport(tag_dict) abort
    return 'using '. get(a:tag_dict, 'namespace', 'error: no import without namespace')
endf
