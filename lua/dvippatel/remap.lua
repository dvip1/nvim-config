-- `space pv` opens the file explorer
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Open netrw" })

-- Move selected lines up/down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Yank to system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Accelerating smooth scroll for j/k (respects counts, e.g. 20j)
local function smooth_scroll(direction)
	local count = vim.v.count1
	local speed = 1
	local max_speed = 10

	local timer = vim.uv.new_timer()
	timer:start(
		0,
		30,
		vim.schedule_wrap(function()
			speed = math.min(speed * 1.3, max_speed)
			local step = math.min(math.floor(speed), count)

			vim.cmd("normal! " .. step .. (direction == "up" and "k" or "j"))

			count = count - step
			if count <= 0 and not timer:is_closing() then
				timer:stop()
				timer:close()
			end
		end)
	)
end

vim.keymap.set("n", "k", function() smooth_scroll("up") end)
vim.keymap.set("n", "j", function() smooth_scroll("down") end)
vim.keymap.set("n", "<Up>", function() smooth_scroll("up") end)
vim.keymap.set("n", "<Down>", function() smooth_scroll("down") end)
