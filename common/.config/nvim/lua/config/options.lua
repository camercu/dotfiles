-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- make netrw default to tree view
vim.g.netrw_liststyle = 3

-- make netrw split open on right
vim.g.netrw_altv = 1

-- when browsing netrw, make <CR> open file by:
--   0: re-using the same window  (default)
--   1: horizontally splitting the window first
--   2: vertically   splitting the window first
--   3: open file in new tab
--   4: act like "P" (ie. open previous window)
--      Note that |g:netrw_preview| may be used
--      to get vertical splitting instead of
--      horizontal splitting.
--   [servername,tab-number,window-number]
--      Given a |List| such as this, a remote server
--      named by the "servername" will be used for
--      editing.  It will also use the specified tab
--      and window numbers to perform editing
--      (see |clientserver|, |netrw-ctrl-r|)
vim.g.netrw_browse_split = 4

-- netrw split takes up 25% of window
vim.g.netrw_winsize = 25
