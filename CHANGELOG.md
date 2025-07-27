# v1.0

## Initial Release 🎉

- Created VQL execution:
    - Created args & parsing for `VeloExec`:
        - Option to specify the `api.client.yaml`;
        - Added param to specify target Fqdn;
        - Special option for running server VQL;
        - Option to delete flows after execution;
    - Created API VQL:
        - Fetch client ID;
        - Start flow on given client + await; 
        - Fetch flow logs;
        - Fetch flow results;
        - Delete the flow;
    - Created result display for Neovim:
        - Opens two windows on success (results, error) & one window on error;
        - Created flow log parsing (for future ideas);
    - Created VIM syntax file for better syntax highlighting on VQL (manual install);
