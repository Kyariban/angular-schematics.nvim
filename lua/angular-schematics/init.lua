local M = {}

M.is_angular_project = function()
	local angular_json = vim.fn.findfile("angular.json", ".;")
	return angular_json ~= ""
end

M.create_schematic = function(schematic_name, name)
	local cmd = "ng generate " .. schematic_name .. " " .. name
	vim.fn.termopen(cmd, { cwd = vim.fn.getcwd() })
end

M.prompt_for_name = function(schematic)
	vim.ui.input({
		prompt = "Enter the name for the " .. schematic .. " :",
	}, function(name)
		if name then
			M.create_schematic(schematic, name)
		end
	end)
end

M.select_schematic = function()
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local conf = require("telescope.config").values

	local schematics = { "component", "service", "module", "directive", "pipe", "guard" }

	pickers
		.new({}, {
			prompt_title = "Select a schematic",
			finder = finders.new_table({
				results = schematics,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(_, map)
				map("i", "<CR>", function(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					if selection then
						M.prompt_for_name(selection.value)
					end
				end)
				return true
			end,
		})
		:find()
end

vim.api.nvim_create_user_command("NgGenerate", function()
	if not M.is_angular_project() then
		vim.notify("Error: Not in an Angular project", vim.log.levels.ERROR)
		return
	end
	M.select_schematic()
end, {})

return M
