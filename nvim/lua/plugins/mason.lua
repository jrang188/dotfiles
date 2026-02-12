return {
  -- Disable mason-lspconfig to prevent automatic LSP installation
  {
    "mason-org/mason-lspconfig.nvim",
    enabled = false,
  },

  -- Disable mason.nvim entirely (optional - remove if you want mason UI but no auto-install)
  {
    "mason-org/mason.nvim",
    enabled = false,
  },
}
