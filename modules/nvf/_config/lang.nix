{
  vim = {
    # spellcheck = {
    #   enable = true;
    #   programmingWordlist.enable = true;
    # };
    diagnostics = {
      config = {
        virtual_text = true;
      };
    };
    languages = {
      enableFormat = true;
      enableTreesitter = true;
      enableExtraDiagnostics = true;

      nix.enable = true;
      tsx.enable = true;
      markdown.enable = true;
      bash.enable = true;
      clang.enable = true;
      css.enable = true;
      html.enable = false;
      json.enable = true;
      typescript.enable = true;
      sql.enable = true;
      go.enable = true;
      lua.enable = true;
      zig.enable = false;
      python.enable = true;
      typst.enable = false;

      rust = {
        enable = true;
        extensions.crates-nvim.enable = true;
      };
      assembly = {
        enable = true;
        lsp.enable = true;
      };
      astro.enable = false; # disabled: nvf's prettier-plugin-astro pnpm hash is stale upstream
      csharp = {
        enable = true;
        lsp.servers = [ "roslyn-ls" ];
      };
      nim.enable = true;
      ocaml.enable = true;
    };
  };
}
