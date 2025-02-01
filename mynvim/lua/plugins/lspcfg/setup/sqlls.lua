
return {
     'nanotee/sqls.nvim',

    require("mason").setup(),
    require("mason-lspconfig").setup({
    }),
    require('lspconfig').sqls.setup{
        cmd = { "sqls" } -- 将sqls放在path，然后手工指定
    }
}
