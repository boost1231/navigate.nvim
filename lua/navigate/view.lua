-- Constants
local BUFFER_OPTIONS = {
    swapfile = false,
    buftype = "nofile",
    modifiable = false,
    filetype = "navigate",
    bufhidden = "hide",
    buflisted = false,
}

-- Data
local navigate_winnr
local last_navigate_bufnr
local config

-- Local Methods
local function create_window()

    local currrent_winnr = vim.api.nvim_get_current_win()

    vim.api.nvim_command("split")
    vim.api.nvim_command("wincmd " .. "J") -- Moves the current window to the bottom
    vim.wo.number = true
    vim.wo.relativenumber = false

    navigate_winnr = vim.api.nvim_get_current_win()

    vim.api.nvim_set_current_win(currrent_winnr)

    vim.api.nvim_win_set_height(navigate_winnr, 10)
end

-- Module
local M = {}

--[[
    {config} = {
        delete_handler = function
        move_mark_down_handler = function
        move_mark_up_handler = function
        go_to_mark_handler = function
        keep_only_handler = function
    }
--]]
M.setup = function(user_config)
    config = user_config
end

M.update_view = function(marks, should_create, current_mark_index)

    local winIds = vim.fn.win_findbuf(last_navigate_bufnr)
    local is_visible = #winIds > 0
    if (not should_create and not is_visible) then
        return
    end

    -- Buffer Setup
    local bufnr = vim.api.nvim_create_buf(false, false)

    -- Add content to the buffer:
    for i, mark in ipairs(marks) do
        local line_num = i - 1
        local line_content = { mark.NormalizedBufName }
        vim.api.nvim_buf_set_lines(bufnr, line_num, line_num, true, line_content)
    end

    vim.keymap.set("n", "<C-r>", config.delete_handler, { noremap = true, buffer = bufnr })
    vim.keymap.set("n", "<C-d>", config.move_mark_down_handler, { noremap = true, buffer = bufnr })
    vim.keymap.set("n", "<C-u>", config.move_mark_up_handler, { noremap = true, buffer = bufnr })
    vim.keymap.set("n", "<C-c>", config.clear_all_marks_handler, { noremap = true, buffer = bufnr })
    vim.keymap.set("n", "<C-k>", config.keep_only_handler, { noremap = true, buffer = bufnr })

    for option, value in pairs(BUFFER_OPTIONS) do
        vim.bo[bufnr][option] = value
    end

    if (is_visible == false) then
        create_window()
    end

    vim.api.nvim_win_set_buf(navigate_winnr, bufnr)

    if last_navigate_bufnr ~= nil then
         vim.api.nvim_command("bwipeout " .. last_navigate_bufnr)
    end

    vim.api.nvim_buf_set_name(bufnr, "navigate")

    -- Here highlight the current line
    vim.api.nvim_buf_add_highlight(bufnr, 0, "Search", current_mark_index - 1, 0, -1)

    last_navigate_bufnr = bufnr
end

M.is_navigate_buffer_current = function()
    local current_bufnr = vim.api.nvim_get_current_buf()

    if (current_bufnr ~= nil and last_navigate_bufnr ~= nil and current_bufnr == last_navigate_bufnr) then
        return true
    end

    return false
end

M.get_navigate_bufnr = function()
    return last_navigate_bufnr
end

return M
