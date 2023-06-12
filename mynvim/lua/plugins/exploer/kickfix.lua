local plugin = {}

plugin.core = {
    'fcpg/vim-kickfix',
}

return plugin


--[==[
    :[range]QDeleteLine                                              *:QDeleteLine*
  Delete lines from the quickfix buffer and the corresponding entries
  from the quickfix list. Also works for the location list.

:QFilterName[!] {pattern}                                        *:QFilterName*
  Keep only filenames matching {pattern} in the quickfix list.
  Discard them if [!].

:LocFilterName[!] {pattern}                                    *:LocFilterName*
  Keep only filenames matching {pattern} in the location list.
  Discard them if [!].

:QFilterContent[!] {pattern}                                  *:QFilterContent*
  Keep only files whose content matches {pattern} in the quickfix list.
  Discard them if [!].

:LocFilterContent[!] {pattern}                              *:LocFilterContent*
  Keep only files whose content matches {pattern} in the location list.
  Discard them if [!].

:QInfo                                                                 *:QInfo*
  Show number of files and number of entries in the quickfix list. Also works
  for the location list.

:QLoad {path}                                                          *:QLoad*
  Load quickfix from {path}.
  Quickfix content can be saved as is with `:w {path}`. Also works for the
  location list.

=============================================================================
PLUG MAPPINGS                                           *kickfix-plug-mappings*

<Plug>(KickfixPreview)
  Open quickfix entry in preview window. Buffer-local.
  Cf. |kickfix-example|

--]==]