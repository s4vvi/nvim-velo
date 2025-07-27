# nvim-velo
Neovim plugin for faster VQL (Velociraptor Query Language) development.

Configuration (Plug):
```lua
Plug = vim.fn['plug#']
vim.call('plug#begin', '~/.config/nvim/plugged')
    Plug 's4vvi/nvim-velo'
vim.call('plug#end')

require('nvim-velo').setup({
    api_config_path = "/home/user/secrets/api.config.yaml", -- Absolute path w/ proper privs
    default_client_fqdn = "localhost", -- Default hostname for running client VQLs 
    delete_flow_after_exec = true -- Whether or not to delete flow's after client VQL
})

vim.filetype.add({
    extension = {
        vql="vql"
    }
})
```

Add the VQL syntax hightlights:
```bash
sudo cp assets/vql.vim /usr/share/nvim/runtime/syntax/
```
