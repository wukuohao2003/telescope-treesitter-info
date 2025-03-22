local actions = require("telescope.actions")
local actions_state = require("telescope.actions.state")
local api = vim.api
local available_parsers = require("nvim-treesitter.parsers").available_parsers()
local conf = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")

api.nvim_set_hl(0, "TelescopeParserInstalled", { fg = "#ddfdd5" })
api.nvim_set_hl(0, "TelescopeParserNotInstalled", { fg = "#f7d2ce" })

local function make_entry(entry)
	local displayer = entry_display.create({
		separator = "",
		items = {
			{ width = 57 },
			{ width = 4 },
			{ remaining = true },
		},
	})

	local make_display = function()
		return displayer({
			{ entry.lang, "Normal" },
			{
				entry.installed and "" or "",
				entry.installed and "TelescopeParserInstalled" or "TelescopeParserNotInstalled",
			},
			{
				entry.installed and "Installed Successfully    " or "    Not Installed       ",
				entry.installed and "TelescopeParserInstalled" or "TelescopeParserNotInstalled",
			},
		})
	end

	return {
		display = make_display,
		value = entry.lang,
		ordinal = entry.lang,
	}
end

--- @return { lang: string, installed: boolean }[]
local function install_info()
	local max_len = 0
	for _, ft in pairs(available_parsers) do
		if #ft > max_len then
			max_len = #ft
		end
	end

	table.sort(available_parsers)

	--- @type { lang: string, display: string, installed: boolean }[]
	local result = {}
	for _, lang in pairs(available_parsers) do
		if #api.nvim_get_runtime_file("parser/" .. lang .. ".so", false) > 0 then
			result[#result + 1] = { lang = lang, check = "", installed = true }
		else
			result[#result + 1] = { lang = lang, check = "", installed = false }
		end
	end

	return result
end

local treesitter_info = {}

treesitter_info.info = function(opts)
	local info = install_info()

	pickers
		.new(opts, {
			prompt_title = "Treesitter Install Info",
			finder = finders.new_table({
				results = info,
				entry_maker = make_entry,
			}),
			sorter = conf.generic_sorter(opts),
			attach_mappings = function(prompt_bufnr, map)
				map("n", "<C-u>", function()
					actions.preview_scrolling_down(prompt_bufnr)
				end)

				actions.select_default:replace(function()
					local selection = actions_state.get_selected_entry()
					if selection == nil then
						vim.notify("No selection", vim.log.levels.ERROR)
					end

					local esc = ""
					if vim.fn.mode() == "i" then
						esc = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
					end

					local selected = info[selection.index]
					local command = selected.installed and "TSUninstall " or "TSInstall "
					vim.api.nvim_feedkeys(string.format("%s:" .. command .. "%s", esc, selected.lang), "m", true)
				end)

				return true
			end,
		})
		:find()
end

api.nvim_create_user_command("TSInstallInfo", treesitter_info.info, { force = true })

return treesitter_info
