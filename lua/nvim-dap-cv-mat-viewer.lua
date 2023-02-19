--
-- nvim-dap-cv-mat-viewer.lua
-- Copyright (C) 2023 David Wright <david.wright@bluewin.ch>
--
-- Distributed under terms of the GPLv3 license.
--
local M = {}

local dap = require("dap")
local a = require("plenary.async")
local sender, receiver = a.control.channel.mpsc()

local pngencoder = require("lua.pngencoder.pngencoder")

local function eval(session, expression)
	session:evaluate(expression, function(err, val)
		sender.send({ err, val })
	end)

	local err, val = table.unpack(receiver.recv())

	if err then
		vim.notify("Could not evaluate expression " .. expression .. ": " .. err.message, "error")
		return nil
	end

	return val
end

local function bgr_to_rgb(bgr_pixel)
	return { bgr_pixel[3], bgr_pixel[2], bgr_pixel[1] }
end

function M.setup()
	-- TODO: Set up nvim commands
end

function M.show(variable)
	a.run(function()
		local session = dap.session()
		if not session then
			vim.notify("No active session", "error")
			return
		end

		if eval(session, variable) == nil then
			return
		end

		local rows = eval(session, variable .. ".rows")
		local cols = eval(session, variable .. ".cols")
		local dims = eval(session, variable .. ".dims")

		-- TODO: how safe is this?
		local step_0 = eval(session, variable .. ".step.buf[0]")
		local step_1 = eval(session, variable .. ".step.buf[1]")

		if rows == nil or cols == nil or step_0 == nil or step_1 == nil or dims == nil then
			return
		end

		dims = tonumber(dims["result"])
		if dims ~= 2 then
			vim.notify("Images of dimensions other than 2 not supported", "warning")
			return
		end

		rows = tonumber(rows["result"])
		cols = tonumber(cols["result"])
		step_0 = tonumber(step_0["result"])
		step_1 = tonumber(step_1["result"])

		-- TODO: Is there a way to find out the exact memory layout?

		local png = pngencoder(cols, rows)

		for row = 1, rows do
			for col = 1, cols do
				local bgr_pixel = {}

				for channel = 1, step_1 do
					local val = eval(
						session,
						variable .. ".data[" .. (row - 1) * step_0 + (col - 1) * step_1 + (channel - 1) .. "]"
					)
					if val then
						bgr_pixel[channel] = tonumber(val["memoryReference"])
					else
						vim.notify("Failed to obtain pixel value", error)
						return nil
					end
				end

				if step_1 == 1 then
					png:write({ bgr_pixel[1], bgr_pixel[1], bgr_pixel[1] })
				else
					png:write(bgr_to_rgb(bgr_pixel))
				end
			end
		end

		if png.done then
			local encoded_image = ""
			for _, value in pairs(png.output) do
				encoded_image = encoded_image .. value
			end
			local log_file = io.open("/home/david/encoded_image.txt", "w")
			io.output(log_file)
			io.write(encoded_image)
			io.close(log_file)
		else
			vim.notify("Failed to encode image", error)
		end
	end)
end

return M
