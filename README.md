# md_nav.nvim

`md_nav.nvim` is a Neovim plugin designed to simplify common Markdown tasks. It
provides utilities for maintaining a Table of Contents (TOC), checking for
frontmatter, and handling footers, enabling users to create well-structured and
consistent Markdown documents effortlessly.

---

## Features

- **TOC Management**: Automatically create and update a nested TOC based on document headings.
- **Footer Insertion**: Add `^top` for navigation and per-section footers.
- **Automatic Updates**: Uses the `BufWritePost` autocmd to trigger TOC and footer updates automatically on file save, with a debounce to prevent excessive calls.
- **Highly Modular**: Clean and modular structure, making it easy to customise.

---

## Installation

Use your preferred Neovim plugin manager to install `md_nav.nvim`.

### With [packer.nvim](https://github.com/wbthomason/packer.nvim):
```lua
use {
  'baphled/md_nav.nvim',
  config = function()
    require('md_nav').setup({
      -- Example configuration options
      max_depth = 3,
      prettify_h1 = true,
      footer_levels = {2, 3},
    })
  end
}
```

### With [vim-plug](https://github.com/junegunn/vim-plug):
```vim
Plug 'baphled/md_nav.nvim'
```

After installation, ensure you run `:PackerSync` or `:PlugInstall` to fetch the plugin.

---

## Usage

The plugin comes pre-configured for basic usage but can be customized to meet your needs. Below are the primary commands and functionalities:

### Commands
- `:MDNav`: Manually generate or update the Table of Contents (TOC) and footers.
- `:MDNavUpdate`: Automatically triggered on file save but can be invoked manually if needed.

### Automatic Updates
The plugin automatically updates the TOC and footers whenever you save your Markdown file. This is achieved using the `BufWritePost` autocmd, ensuring your document remains consistent without manual intervention.

### Example
Here's an example of how the plugin ensures a consistent TOC and footers:

Before:
```markdown
# Example Document

## Section 1
Some content.

## Section 2
More content.
```

After running `:MDNav`:
```markdown
# Example Document

## Table of Contents
- [Section 1](#section-1)
- [Section 2](#section-2)

## Section 1
Some content.

^top

## Section 2
More content.

^top
```

---

### Frontmatter Handling
The plugin ensures that a frontmatter block (if present) is consistent and correctly formatted. If an H1 header is missing, it will automatically insert one directly below the frontmatter.

Example:

Before:
```markdown
---
key: value
---

## Section 1
```

After running `:MDNav`:
```markdown
---
key: value
---

# Document Title

## Section 1
```

---

## Configuration

Customize the plugin by passing options to the `setup` function. Below are some examples:

```lua
require('md_nav').setup({
  max_depth = 3,         -- Maximum depth for TOC
  footer_levels = {2},  -- Add footers only to H2 headers
  prettify_h1 = true,   -- Ensure H1 headers have a specific format
})
```

---

## Development

### Running Tests
Tests are written using `neotest-plenary`. Run the following command to execute the test suite:
```bash
nvim --headless -c "PlenaryBustedDirectory spec/ {minimal_init = 'spec/minimal_init.lua'}"
```

### Minimum Requirements
- Neovim 0.7.0 or higher
- Lua 5.1 or higher

### Contributing
We welcome contributions! Please ensure your changes are well-documented and include tests where applicable. Open an issue or submit a pull request on GitHub.

### Troubleshooting
If you encounter issues, ensure:
- The plugin is correctly installed.
- Your Neovim version meets the minimum requirements.
- Refer to the logs for specific error messages.

---

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

