---@class setup_opts
---@field lualine_theme_dir string
---@field pairs table

---@class colorsync
---@field setup fun(opts: table)
---@field opts setup_opts
---@field set_theme fun(theme: string)
---@field pick_theme fun()

---@type colorsync
local M = {}

---@param opts setup_opts
M.setup = function(opts)
	M.opts = opts
	vim.api.nvim_create_user_command("ColorSync", function()
		M.pick_theme()
	end, { bang = false })
end

---@return string?
---@param array table
---@param callback fun(selected: string)
local picker = function(array, callback)
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	local opts = require("telescope.themes").get_dropdown()

	return pickers
		.new(opts, {
			prompt_title = "colors",
			finder = finders.new_table({
				results = array,
			}),
			sorter = conf.generic_sorter(opts),

			attach_mappings = function(prompt_bufnr, _)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					callback(selection[1])
				end)
				return true
			end,
		})
		:find()
end

M.set_theme = function(theme)
	vim.cmd({
		cmd = "colorscheme",
		args = { theme },
	})

	local lualine_config = M.opts.pairs[theme]
	if lualine_config then
		require(M.opts.lualine_theme_dir .. "." .. lualine_config)()
	else
		print("No lualine config found for " .. theme)
	end
end

M.pick_theme = function()
	local themes = {}
	for k, _ in pairs(M.opts.pairs) do
		table.insert(themes, k)
	end

	picker(themes, function(selected)
		M.set_theme(selected)
	end)
end

return M
