### Readme
this project is a linux-like operate system running on i386 intel chip.

#### build and run.
install bear to generate compile_commands.json for clangd
```bash
    sudo apt install bear
    bear make all && make play
```
just play.
```bash
    make clean && make all && make play
```

### clangd settings.
The core configuration settings of the clangd, modify the installation location of the clangd as needed. After restarting the clangd lsp service, there can be code auto-completion, call hierarchies, auto-jumps, and so on.
The same applies to editors that support LSP, such as Neovim
```c
/home/levan/.vscode-server/data/Machine/settings.json
{
    "C_Cpp.intelliSenseEngine": "disabled",
    "clangd.path": "/home/levan/.vscode-server/data/User/globalStorage/llvm-vs-code-extensions.vscode-clangd/install/18.1.3/clangd_18.1.3/bin/clangd",
    "clangd.arguments": [
        "-log=verbose",
        "--background-index",
        "--compile-commands-dir=${workspaceFolder}"
    ]
}
```