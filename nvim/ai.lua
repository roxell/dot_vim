-- AI coding agents: claude code and opencode.
--
-- Both run in a terminal split on the right. The keymaps under <leader>a
-- are shared, and <leader>ag picks which agent they talk to.

-- vim-plug has not installed the plugins yet on a fresh checkout.
if not pcall(require, "snacks") then
	return
end

-- vim-plug does not call setup() for us, lazy.nvim would have.
require("snacks").setup({
	input = { enabled = true },
	picker = { enabled = true },
	terminal = { enabled = true },
})

require("claudecode").setup({
	terminal_cmd = vim.fn.exepath("claude"),
})

local opencode_cmd = "opencode --port"
local terminal_opts = { win = { position = "right", enter = false } }

vim.g.opencode_opts = {
	server = {
		start = function()
			require("snacks.terminal").open(opencode_cmd, terminal_opts)
		end,
	},
}

vim.g.active_agent = "claude"

local actions = {
	toggle = {
		claude = function() vim.cmd("ClaudeCode") end,
		opencode = function() require("snacks.terminal").toggle(opencode_cmd, terminal_opts) end,
	},
	send = {
		claude = function() vim.cmd("ClaudeCodeSend") end,
		opencode = function() require("opencode").ask("@this: ", { submit = true }) end,
	},
	add_file = {
		claude = function() vim.cmd("ClaudeCodeAdd %") end,
		opencode = function() require("opencode").prompt("@this") end,
	},
	select = {
		claude = function() vim.cmd("ClaudeCodeSelectModel") end,
		opencode = function() require("opencode").select() end,
	},
}

local function agent(action)
	return function() actions[action][vim.g.active_agent]() end
end

local map = vim.keymap.set

map("n", "<leader>aa", agent("toggle"), { desc = "AI: open or close the agent" })
map("n", "<leader>af", agent("add_file"), { desc = "AI: add file to context" })
map("n", "<leader>am", agent("select"), { desc = "AI: pick model" })
map("x", "<leader>as", agent("send"), { desc = "AI: send selection" })

-- claude sends a range, so select the line first when we come from normal mode.
map("n", "<leader>as", function()
	vim.cmd("normal! V")
	agent("send")()
end, { desc = "AI: send line" })

map("n", "<leader>a?", function()
	require("snacks").picker.keymaps()
end, { desc = "AI: show the keymaps" })

map("n", "<leader>ag", function()
	vim.g.active_agent = vim.g.active_agent == "claude" and "opencode" or "claude"
	vim.notify("AI agent: " .. vim.g.active_agent)
end, { desc = "AI: switch agent" })
