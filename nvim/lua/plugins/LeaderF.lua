local plugin = {}

plugin.core = {
    'Yggdroot/LeaderF',
    'tamago324/LeaderF-filer',
    run = ':LeaderfInstallCExtension',
    as = "leaderf",
    vim.cmd([[
    "let g:Lf_WindowPosition = 'fullScreen'
    let g:Lf_WindowPosition = 'popup'
    let g:Lf_WorkingDirectoryMode = 'F'
    let g:Lf_PreviewInPopup = 1
    let g:Lf_PreviewInPopup = 1
    let g:Lf_StlSeparator = { 'left': "\ue0b0", 'right': "\ue0b2", 'font': "DejaVu Sans Mono for Powerline" }
    "自动生成tags
    let g:Lf_GtagsAutoGenerate = 1  
    let g:Lf_CommandMap = {'<C-K>': ['<c-p>'], '<C-J>': ['<c-n>']}
    let g:Lf_StlSeparator = { 'left': '', 'right': '', 'font': '' }
    let g:Lf_RootMarkers = ['.project', '.root', '.svn', '.git']
    let g:Lf_WorkingDirectoryMode = 'Ac'
    let g:Lf_WindowHeight = 0.30
    let g:Lf_CacheDirectory = expand('~/.cache/')
    let g:Lf_ShowRelativePath = 0
    let g:Lf_HideHelp = 1
    let g:Lf_StlColorscheme = 'powerline'
    let g:Lf_PreviewResult = {'Function':0, 'BufTag':0}
    let g:Lf_ShortcutF = "<leader>ff"
    ]]),

    config = function() -- Specifies code to run after this plugin is loaded

        --[===[
        vim.cmd([[
        nnoremap <c-c><c-f> :Leaderf rg <SPACE>
        " noremap <c-x><c-f> :<C-U><C-R>=printf("Leaderf! rg -e %s ", expand("<cword>"))<CR>
        "select file from current floder
        " select from opened buffer
        noremap fb :<C-U><C-R>=printf("Leaderf buffer %s", "")<CR><CR>
        " select from history
        noremap fh :<C-U><C-R>=printf("Leaderf mru %s", "")<CR><CR>
        "select from current buffer
        noremap fl :<C-U><C-R>=printf("Leaderf line %s", "")<CR><CR>
        xnoremap fg :<C-U><C-R>=printf("Leaderf! rg -F -e %s ", leaderf#Rg#visual())<CR>
        noremap fp :<C-U>Leaderf! rg --recall<CR>

        noremap fgr :<C-U><C-R>=printf("Leaderf! gtags -r %s --auto-jump", expand("<cword>"))<CR><CR>
        noremap fgd :<C-U><C-R>=printf("Leaderf! gtags -d %s --auto-jump", expand("<cword>"))<CR><CR>
        noremap fgo :<C-U><C-R>=printf("Leaderf! gtags --recall %s", "")<CR><CR>
        noremap fgn :<C-U><C-R>=printf("Leaderf gtags --next %s", "")<CR><CR>
        noremap fgp :<C-U><C-R>=printf("Leaderf gtags --previous %s", "")<CR><CR>


        noremap <m-h> :Leaderf! mru<cr>
        noremap <m-f> :LeaderfFunction!<cr>
        noremap <m-b> :Leaderf! buffer<cr>
        noremap <m-t> :LeaderfTag<cr>
        ]])
        --]===]
    end
}

plugin.mapping = function()

    -- vim.api.nvim_set_keymap("n","<Leader>find",[[':<C-u>%s/\<' . expand('<cword>') . '\>//g<Left><Left>']], { noremap = true, silent = false, expr = true })
    -- key =  { "<Leader>","s", "w" },
    -- action = [[<Cmd>execute('Leaderf! rg -e '. expand("<cword>") . '<CR>']]
    -- action =[[':<C-u>Leaderf! rg -e ' . expand('<cword>')]],
    --    action = [[':<C-u>Leaderf! rg -e ' . expand('<cword>.) . '<CR>']],

    -- keymap("n", "<Leader>sg", [[':<C-u>%s/\<' . expand('<cword>') . '\>//g<Left><Left>']], { noremap = true, silent = false, expr = true })
    -- vim.fn.expand("<cword>")

    local keymap = require('core.keymapping')
    keymap.register({
        mode = {"n"},
        key = {"<leader>","l","s"},
        action = [[':<C-u>Leaderf!  --popup  rg -e ']],
        short_desc = "Search CurrentWord",
        expr = true
    })

    keymap.register({
        mode = {"n"},
        key = {"<leader>","l","w"},
        action = [[':<C-u>Leaderf! rg -e ' . expand('<cword>')]],
        short_desc = "Search CurrentWord",
        expr = true
    })

    keymap.register({
        mode = {"n"},
        key = {"m","n"},
        action = ':LeaderfMru<CR>',
        short_desc = "Open Mru",
    })


    keymap.register({
        mode = {"n"},
        key = {"<leader>","l","f"},
        action = ':LeaderfFunction<CR>',
        short_desc = "List Functions",
    })

    keymap.register({
        mode = {"n"},
        key = {"<leader>","l","b"},
        action = ':Leaderf! buffer<CR>',
        short_desc = "List Buffers",
    })


    keymap.register({
        mode = {"n"},
        key = {"<leader>","l","l"},
        action = ':Leaderf! rg --recall<CR>',
        short_desc = "List Buffers",
    })


    keymap.register({
        mode = {"n"},
        key = {"<leader>","l","h"},
        action = ':Leaderf! filer<CR>',
        short_desc = "List Buffers",
    })

    --[===[
    --leaderf filer command
    H	history_backward	Go backwards in history.
    L	history_forward	Go forwards in history.
    K	mkdir	Create a directory.
        See g:Lf_FilerMkdirAutoChdir
    O	create_file	Create a file.
    R	rename	Rename files and directories.
    C	copy	Copy files and directories under cursor.
    P	paste	Paste the file or directory copied by the copy command to cwd of LeaderF-filer.
    --]===]

end

return plugin
