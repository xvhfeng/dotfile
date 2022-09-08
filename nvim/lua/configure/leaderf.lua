local plugin = {}

plugin.core = {
    'Yggdroot/LeaderF', 
    opt_marker = "模糊查询插件",
   opt_enable = false,


    run = ':LeaderfInstallCExtension',
    as = "leaderf",
    --run = ":LeaderfInstallCExtension",
    --cmd = { "LeaderF" },
    setup = function() -- Specifies code to run before this plugin is loaded.
        vim.cmd([[
            let g:Lf_WorkingDirectoryMode = 'F'
let g:Lf_WindowPosition = 'fullScreen'
let g:Lf_PreviewInPopup = 1
let g:Lf_StlSeparator = { 'left': "\ue0b0", 'right': "\ue0b2", 'font': "DejaVu Sans Mono for Powerline" }
"let g:Lf_PreviewResult = {'Function': 0, 'BufTag': 0 }

nnoremap <c-c><c-f> :Leaderf rg <SPACE>
noremap <c-x><c-f> :<C-U><C-R>=printf("Leaderf! rg -e %s ", expand("<cword>"))<CR>
"select file from current floder
let g:Lf_ShortcutF = "<leader>ff"
" select from opened buffer
noremap fb :<C-U><C-R>=printf("Leaderf buffer %s", "")<CR><CR>
" select from history
noremap fh :<C-U><C-R>=printf("Leaderf mru %s", "")<CR><CR>
"select from current buffer
noremap fl :<C-U><C-R>=printf("Leaderf line %s", "")<CR><CR>
xnoremap fg :<C-U><C-R>=printf("Leaderf! rg -F -e %s ", leaderf#Rg#visual())<CR>
noremap fp :<C-U>Leaderf! rg --recall<CR>
"自动生成tags
let g:Lf_GtagsAutoGenerate = 1
noremap fgr :<C-U><C-R>=printf("Leaderf! gtags -r %s --auto-jump", expand("<cword>"))<CR><CR>
noremap fgd :<C-U><C-R>=printf("Leaderf! gtags -d %s --auto-jump", expand("<cword>"))<CR><CR>
noremap fgo :<C-U><C-R>=printf("Leaderf! gtags --recall %s", "")<CR><CR>
noremap fgn :<C-U><C-R>=printf("Leaderf gtags --next %s", "")<CR><CR>
noremap fgp :<C-U><C-R>=printf("Leaderf gtags --previous %s", "")<CR><CR>


noremap <m-h> :Leaderf! mru<cr>
noremap <m-f> :LeaderfFunction!<cr>
noremap <m-b> :Leaderf! buffer<cr>
noremap <m-t> :LeaderfTag<cr>
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
            ]])
        --vim.g.Lf_PreviewInPopup = 1
    end,

    config = function() -- Specifies code to run after this plugin is loaded
    end,
}

plugin.mapping = function()

end

return plugin
