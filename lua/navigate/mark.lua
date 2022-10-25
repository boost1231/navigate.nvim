local Path = require("plenary.path")

local marks = {}
local current_mark_index = 1

local function normalize_path(item)
    return Path:new(item):make_relative(vim.loop.cwd())
end

local function is_index_in_marks(mark_index)
    return mark_index > 0 and mark_index <= #marks
end

local M = {}

M.create_mark = function()
    local cursor_position = vim.api.nvim_win_get_cursor(0)

    local bufname = vim.api.nvim_buf_get_name(0)

    local normalized_bufname = normalize_path(bufname)

    table.insert(marks, {
        CursorRow = cursor_position[1],
        CursorColumn = cursor_position[2],
        BufName = bufname,
        NormalizedBufName = normalized_bufname,
    })

    current_mark_index = #marks
end

M.set_current_markindex = function(mark_index)
    if not is_index_in_marks(mark_index) then
        print("Index not in marks")
        return
    end
    current_mark_index = mark_index
end

M.move_to_previous_mark = function()
    local previous_index = current_mark_index - 1

    if (current_mark_index == 1) then
       previous_index = #marks
    end

    M.set_current_markindex(previous_index)
end

M.move_to_next_mark = function()
    local next_index = current_mark_index + 1

    if (current_mark_index == #marks) then
       next_index = 1
    end

    M.set_current_markindex(next_index)
end

M.delete_mark = function(mark_index)
    if not is_index_in_marks(mark_index) then
        print("The mark requested to be removed already does not exist")
        return
    end

    table.remove(marks, mark_index)

    if mark_index <= current_mark_index then
        M.move_to_previous_mark()
    end
end

M.move_mark_down = function(mark_index)
    if not is_index_in_marks(mark_index) then
        print ("The mark requested to be moved down does not exist")
        return
    end

    if mark_index == #marks then
        print("The last mark cannot be moved down")
        return
    end

    local mark = table.remove(marks, mark_index)

    local new_mark_index = mark_index + 1

    table.insert(marks, new_mark_index, mark)

    if current_mark_index == mark_index then
        M.set_current_markindex(current_mark_index + 1)
    elseif current_mark_index == new_mark_index then
        M.set_current_markindex(current_mark_index - 1)
    end
end

M.move_mark_up = function(mark_index)
    if not is_index_in_marks(mark_index) then
        print ("The mark requested to be moved up does not exist")
        return
    end

    if mark_index == 1 then
        print ("The first mark cannot be moved up")
    end

    local mark = table.remove(marks, mark_index)

    local new_mark_index = mark_index - 1

    table.insert(marks, new_mark_index, mark)

    if current_mark_index == mark_index then
        M.set_current_markindex(current_mark_index - 1)
    elseif current_mark_index == new_mark_index then
        M.set_current_markindex(current_mark_index + 1)
    end
end

M.clear_all_marks = function()
    marks = {}
    current_mark_index = 1
end

M.keep_only = function(mark_index)
    if not is_index_in_marks(mark_index) then
        print ("The mark requested to be kept does not exist.")
        return
    end

    local mark = marks[mark_index]

    marks = {}
    table.insert(marks, mark)

    current_mark_index = 1
end

M.get_marks = function()
    return {
        marks = marks,
        current_mark_index = current_mark_index
    }
end

return M
