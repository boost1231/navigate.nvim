

local M = {}

M.get_entity_name = function(node)

    local identifier_node

    for child in node:iter_children() do
        if child:type() == "identifier" then
            identifier_node = child
            break
        end
    end

    if identifier_node == nil then
        return "Entity_Name_Not_Found"
    end

    return vim.treesitter.query.get_node_text(identifier_node, 0)
end

M.get_method_name = function(node)

    local identifier_node

    for child in node:iter_children() do

        local row, col = child:start()

        local captures = vim.treesitter.get_captures_at_pos(0, row, col)

        if captures ~= nil then

            local is_method = false

            for _, value in ipairs(captures) do
                if value.capture == "method" then
                    is_method = true
                    break
                end
            end

            if is_method and child:type() == "identifier" then
                identifier_node = child
                break
            end
        end
    end

    if identifier_node == nil then
        return "Entity_Name_Not_Found"
    end

    return vim.treesitter.query.get_node_text(identifier_node, 0)
end

M.find_parent_method_name = function()

    local node = require("nvim-treesitter.ts_utils").get_node_at_cursor(0)

    if node == nil then return "No_Node_Under_Cursor" end

    while node ~= nil and node:type() ~= "method_declaration" do
        node = node:parent()
    end

    if node == nil then return "Method_Declaration_Not_Found" end

    return M.get_method_name(node)
end

M.find_parent_type_name = function()

    local node = require("nvim-treesitter.ts_utils").get_node_at_cursor(0)

    if node == nil then return "No_Node_Under_Cursor" end

    while node ~= nil and node:type() ~= "class_declaration" and node:type() ~= "record_declaration" and node:type() ~= "struct_declaration" do
        node = node:parent()
    end

    if node == nil then return "Parent_Type_Not_Found" end

    return M.get_entity_name(node)
end


return M;
