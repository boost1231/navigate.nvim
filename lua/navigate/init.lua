-- Rather than grabbing the name of the buf,
-- I think I should grab the name of the class and method
-- that I'm currently in. Maybe the plug in can be navigate_callstack.
-- The table I would need to store would be:
-- { bufname, cursor_row, cursor_col, class_name, method_name }
-- bufname, cursor_row, cursor_col would be to navigate when this 
-- mark is chosen, class_name method_name and cursor_row, cursor_col would be for display
-- The benifit of using the ful filename, is it doesn't matter if the buffer gets closed.
-- If I know I will keep the buffer open, then maybe I could use buffer Id's?
-- Actually I was thinking displaying Class/Method, but not all languages have that 
-- structure, maybe it would be better to show the relative path instead.
-- Maybe could make it configurable, to either do file name, or class/method name.
-- You could maybe make the function that choose what to do display configurable, and
-- could maybe attach it when an LSP loads.

-- It seems like scratch buffers get created. Look into seeing how to avoid that.
-- Could set the window height based on the number of marks with a min of maybe 10 rows?
-- When splitting the window don't move the cursor there.
-- For now I can navigate by just doing a key mapping where I pass in an index.
-- implement previous and next, so that I can cycle the buffer.
-- See if you can get the current mark hightlighted.
--
-- I think to reorder buffers, I could make a move_up and move_down method.
-- It would just take the current mark and substitute position with the one
-- above or below it.
-- Also need to add close functionality.
-- I think I need to maybe have the current buf highlighted.
-- Then when one moves the cursor into the window we could make commands
-- to move order of buffers and delete buffers
-- In order to show the current buffer, I could also maybe just prefix 
-- the line with a *
local View = require("navigate.view")
local Mark = require("navigate.mark")
local Utility = require("navigate.utility")

print("Loading init.lua")

local function get_mark_index()
    return vim.api.nvim_win_get_cursor(0)
end

local function update_view(should_create_optional)
    local should_create = false

    if should_create_optional then
        should_create = should_create_optional
    end

    local data = Mark.get_marks()
    View.update_view(data.marks, should_create, data.current_mark_index)
end

-- Module
local M = {}

M.delete_mark = function()
    if not View.is_navigate_buffer_current() then
        print("This command can only be run in the navigate buffer.")
        return
    end

    local mark_index = get_mark_index()
    Mark.delete_mark(mark_index[1])
    update_view()
end

M.move_mark_down = function()
    if not View.is_navigate_buffer_current() then
        print("This command can only be run in the navigate buffer.")
        return
    end

    local mark_index = get_mark_index()
    Mark.move_mark_down(mark_index[1])
    update_view()
    vim.api.nvim_win_set_cursor(0, { mark_index[1] + 1, mark_index[2] })
end

M.move_mark_up = function()
    if not View.is_navigate_buffer_current() then
        print("This command can only be run in the navigate buffer.")
        return
    end

    local mark_index = get_mark_index()
    Mark.move_mark_up(mark_index[1])
    update_view()
    vim.api.nvim_win_set_cursor(0, { mark_index[1] - 1, mark_index[2] })
end

M.clear_all_marks = function()
    if not View.is_navigate_buffer_current() then
        print("This command can only be run in the navigate buffer.")
        return
    end

    Mark.clear_all_marks()
    update_view()
end

M.keep_only = function()
    if not View.is_navigate_buffer_current() then
        print("This command can only be run in the navigate buffer.")
        return
    end

    local mark_index = get_mark_index()
    Mark.keep_only(mark_index[1])
    update_view()
end

M.open = function()
    update_view(true)
end

M.mark = function()
    Mark.create_mark();
    update_view()
end

M.navigate_to_current_index = function()
    local data = Mark.get_marks();
    local mark = data.marks[data.current_mark_index]
    local bufnr = Utility.get_or_create_buffer(mark.BufName)
    vim.api.nvim_set_current_buf(bufnr)
    vim.api.nvim_buf_set_option(bufnr, "buflisted", true)
    vim.api.nvim_win_set_cursor(0, { mark.CursorRow, mark.CursorColumn } )
    update_view()
end

M.previous = function()
    Mark.move_to_previous_mark()
    M.navigate_to_current_index()
end

M.next = function()
    Mark.move_to_next_mark()
    M.navigate_to_current_index();
end

M.navigate_to_mark = function(mark_index)
    Mark.set_current_markindex(mark_index)
    M.navigate_to_current_index()
end

View.setup({
    delete_handler = M.delete_mark,
    move_mark_down_handler = M.move_mark_down,
    move_mark_up_handler = M.move_mark_up,
    clear_all_marks_handler = M.clear_all_marks,
    keep_only_handler = M.keep_only,
})

return M
