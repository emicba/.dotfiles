local packer_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'

if not vim.loop.fs_stat(packer_path) then
  vim.fn.system {
    'git',
    'clone',
    '--depth',
    '1',
    'https://github.com/wbthomason/packer.nvim.git',
    packer_path,
  }
  vim.cmd [[packadd packer.nvim]]
end

return require('packer').startup(function(use)
  -- Packer can manage itself
  use { 'wbthomason/packer.nvim', commit = 'ed2d5c9c17f4df2eeaca4878145fecc9669e0138' }

  use {
    'nvim-telescope/telescope.nvim',
    commit = 'a3f17d3baf70df58b9d3544ea30abe52a7a832c2',
    requires = { { 'nvim-lua/plenary.nvim', commit = '253d34830709d690f013daf2853a9d21ad7accab' } },
  }

  use {
    'nvim-telescope/telescope-fzf-native.nvim',
    commit = '580b6c48651cabb63455e97d7e131ed557b8c7e2',
    run = 'make',
  }

  use {
    'github/copilot.vim',
    commit = '9e869d29e62e36b7eb6fb238a4ca6a6237e7d78b',
  }
end)
