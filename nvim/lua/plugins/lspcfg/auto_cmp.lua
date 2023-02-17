local plugin = {}
--[[
cd ~/.local/share/nvim/site/pack/packer/start/YouCompleteMe
git submodule update --init --recursive
ln -s `pwd`/.ycm_extra_conf.py ~/.ycm_extra_conf.py
--]]

plugin.core = {
    --"ycm-core/YouCompleteMe",

    'prabirshrestha/asyncomplete.vim',
    'prabirshrestha/asyncomplete-tags.vim',
    'keremc/asyncomplete-clang.vim',

    vim.cmd [==[

    inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
    inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
    inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"
    inoremap <expr> <cr> pumvisible() ? asyncomplete#close_popup() . "\<cr>" : "\<cr>"

    let g:asyncomplete_auto_popup = 1
    let g:asyncomplete_auto_completeopt = 0
    set completeopt=menuone,noinsert,noselect,preview
    autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

    function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
    endfunction

    inoremap <silent><expr> <TAB>
    \ pumvisible() ? "\<C-n>" :
    \ <SID>check_back_space() ? "\<TAB>" :
    \ asyncomplete#force_refresh()
    inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"


    au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#tags#get_source_options({
    \ 'name': 'tags',
    \ 'allowlist': ['c'],
    \ 'completor': function('asyncomplete#sources#tags#completor'),
    \ 'config': {
    \    'max_file_size': 50000000,
    \  },
    \ }))

    autocmd User asyncomplete_setup call asyncomplete#register_source(
    \ asyncomplete#sources#clang#get_source_options())

    autocmd User asyncomplete_setup call asyncomplete#register_source(
    \ asyncomplete#sources#clang#get_source_options({
    \     'config': {
    \         'clang_path': '/usr/bin/clang',
    \         'clang_args': {
    \             'default': ['-I/usr/include','-I/usr/local/include'],
    \             'cpp': ['-std=c++11', '-I/usr/include','-I/usr/local/include']
    \         }
    \     }
    \ }))
    ]==]

}

return plugin
