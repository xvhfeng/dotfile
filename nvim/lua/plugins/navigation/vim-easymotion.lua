local plugin = {}

plugin.core = {
    'easymotion/vim-easymotion',
    after = {
        {'haya14busa/incsearch.vim'},
        {'haya14busa/incsearch-easymotion.vim'}
    },
    vim.cmd [[
    function! s:incsearch_config(...) abort
    return incsearch#util#deepextend(deepcopy({
        \   'modules': [incsearch#config#easymotion#module({'overwin': 1})],
        \   'keymap': {
            \     "\<CR>": '<Over>(easymotion)'
            \   },
            \   'is_expr': 0
            \ }), get(a:, 1, {}))
            endfunction

            noremap <silent><expr> /  incsearch#go(<SID>incsearch_config())
            noremap <silent><expr> ?  incsearch#go(<SID>incsearch_config({'command': '?'}))
            noremap <silent><expr> g/ incsearch#go(<SID>incsearch_config({'is_stay': 1}))
            ]]

        }

        plugin.mapping = function()

            vim.cmd[[
            map <Leader>p <Plug>(easymotion-prefix)

            " <Leader>f{char} to move to {char}
            map  <Leader>f <Plug>(easymotion-bd-f)
            nmap <Leader>f <Plug>(easymotion-overwin-f)

            " s{char}{char} to move to {char}{char}
            nmap F <Plug>(easymotion-overwin-f2)

            " Move to line
            map <Leader>L <Plug>(easymotion-bd-jk)
            nmap <Leader>L <Plug>(easymotion-overwin-line)

            " Move to word
            map  <Leader>w <Plug>(easymotion-bd-w)
            nmap <Leader>w <Plug>(easymotion-overwin-w)

            " Gif config
            " nmap F <Plug>(easymotion-s2)
            " nmap t <Plug>(easymotion-t2)

            " Gif config
            map  / <Plug>(easymotion-sn)
            omap / <Plug>(easymotion-tn)

            " These `n` & `N` mappings are options. You do not have to map `n` & `N` to EasyMotion.
            " Without these mappings, `n` & `N` works fine. (These mappings just provide
            " different highlight method and have some other features )
            map  n <Plug>(easymotion-next)
            map  N <Plug>(easymotion-prev)

            " Gif config
            map <Leader>l <Plug>(easymotion-lineforward)
            map <Leader>j <Plug>(easymotion-j)
            map <Leader>k <Plug>(easymotion-k)
            map <Leader>h <Plug>(easymotion-linebackward)

            let g:EasyMotion_startofline = 0 " keep cursor column when JK motion

            let g:EasyMotion_smartcase = 1

            let g:EasyMotion_use_smartsign_us = 1 " US layout

            " Gif config

            " Require tpope/vim-repeat to enable dot repeat support
            " Jump to anywhere with only `s{char}{target}`
            " `s<CR>` repeat last find motion.
            nmap F <Plug>(easymotion-s)
            " Bidirectional & within line 't' motion
            " omap t <Plug>(easymotion-bd-tl)
            " Use uppercase target labels and type as a lower case
            let g:EasyMotion_use_upper = 1
            " type `l` and match `l`&`L`
            let g:EasyMotion_smartcase = 1
            " Smartsign (type `3` and match `3`&`#`)
            let g:EasyMotion_use_smartsign_us = 1
            ]]
        end

        return plugin
