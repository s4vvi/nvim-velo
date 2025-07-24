# nvim-velo
Neovim plugin for faster VQL (Velociraptor Query Language) development.

Configuration:
```lua
require('nvim-velo').setup({
    api_config_path = "./api.config.yaml",
    default_client_fqdn = "localhost", -- Default hostname for running client VQLs 
    delete_flow_after_exec = true -- Whether or not to delete flow's after client VQL
})

vim.filetype.add({
    extension = {
        vql="vql"
    }
})
```
