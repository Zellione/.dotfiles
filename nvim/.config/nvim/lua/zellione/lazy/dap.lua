return {
	"rcarriga/nvim-dap-ui",
	dependencies = {
		"mfussenegger/nvim-dap",
		"nvim-neotest/nvim-nio",
		"mxsdev/nvim-dap-vscode-js",
	},
	config = function()
		require("dap-vscode-js").setup({
			-- node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
			debugger_path = "/Users/sna06/.local/share/nvim/lazy/vscode-js-debug", -- Path to vscode-js-debug installation.
			-- debugger_cmd = { "js-debug-adapter" }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
			adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" }, -- which adapters to register in nvim-dap
			-- log_file_path = "(stdpath cache)/dap_vscode_js.log" -- Path for file logging
			-- log_file_level = false -- Logging level for output to file. Set to false to disable file logging.
			-- log_console_level = vim.log.levels.ERROR -- Logging level for output to console. Set to false to disable console output.
		})

		local dap = require("dap")

		dap.adapters.gdb = {
			type = "executable",
			command = "gdb",
			args = { "-i", "dap" },
		}

		dap.adapters.lldb = {
			type = "executable",
			command = "/usr/bin/lldb-vscode", -- adjust as needed, must be absolute path
			name = "lldb",
		}

		-- dap.adapters.chrome = {
		-- 	type = "executable",
		-- 	command = "node",
		-- 	args = {
		-- 		os.getenv("HOME") .. "/.local/share/nvim/lsp-debuggers/vscode-chrome-debug/out/src/chromeDebug.js",
		-- 	},
		-- }

		-- dap.adapters["pwa-node"] = {
		-- 	type = "executable",
		-- 	executable = {
		-- 		command = "node-debug2-adapter",
		-- 	},
		-- }

		-- dap.adapters["pwa-node"] = {
		-- 	type = "server",
		-- 	host = "::1",
		-- 	port = "${port}",
		-- 	executable = {
		-- 		command = "node",
		-- 		args = {
		-- 			os.getenv("HOME") .. "/.local/share/nvim/lsp-debuggers/js-debug/src/dapDebugServer.js",
		-- 			"${port}",
		-- 		},
		-- 	},
		-- }

		-- dap.adapters["pwa-node"] = {
		-- 	type = "server",
		-- 	host = "::1",
		-- 	port = "${port}",
		-- 	executable = {
		-- 		command = "js-debug-adapter",
		-- 		args = {
		-- 			"${port}",
		-- 		},
		-- 	},
		-- }

		dap.configurations.typescript = {
			{
				name = "Debug ConfigServer",
				type = "pwa-node",
				request = "attach",
				address = "localhost",
				port = "9002",
				-- resolveSourceMapLocations = {
				-- 	"${workspaceFolder}/dist/apps/charybdis/**",
				-- },
				outFiles = { "${workspaceFolder}/dist/apps/config-server/**" },
				localRoot = "${workspaceFolder}/apps/config-server",
				remoteRoot = "/Users/sna06/projects/nh-storefront/apps/config-server",
				cwd = "${workspaceFolder}/apps/config-server",
				-- rootPath = "${workspaceFolder}/apps/charybdis/src",
				-- sourceMaps = true,
				restart = true,
				-- protocol = "inspector",
				-- trace = true,
				skipFiles = { "<node_internals>/**", "node_modules/**" },
			},
			{
				name = "Debug Charybdis",
				type = "pwa-node",
				request = "attach",
				address = "localhost",
				port = "9001",
				-- resolveSourceMapLocations = {
				-- 	"${workspaceFolder}/dist/apps/charybdis/**",
				-- },
				outFiles = { "${workspaceFolder}/dist/apps/charybdis/**" },
				localRoot = "${workspaceFolder}/apps/charybdis",
				remoteRoot = "/Users/sna06/projects/nh-storefront/apps/charybdis",
				cwd = "${workspaceFolder}/apps/charybdis",
				-- rootPath = "${workspaceFolder}/apps/charybdis/src",
				-- sourceMaps = true,
				restart = true,
				-- protocol = "inspector",
				-- trace = true,
				skipFiles = { "<node_internals>/**", "node_modules/**" },
			},
			{
				name = "Debug (Attach) Remote",
				type = "chrome",
				request = "attach",
				sourceMaps = true,
				trace = true,
				port = 9001,
				webRoot = "${workspaceFolder}/app/charybdis",
			},
			{
				type = "pwa-node",
				request = "attach",
				name = "Attach",
				processId = require("dap.utils").pick_process,
				cwd = "${workspaceFolder}",
			},
		}

		dap.configurations.cpp = {
			{
				name = "Launch",
				type = "lldb",
				request = "launch",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = false,
				args = {},

				-- 💀
				-- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
				--
				--    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
				--
				-- Otherwise you might get the following error:
				--
				--    Error on launch: Failed to attach to the target process
				--
				-- But you should be aware of the implications:
				-- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
				-- runInTerminal = false,
			},
			{
				-- If you get an "Operation not permitted" error using this, try disabling YAMA:
				--  echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
				name = "Attach to process",
				type = "cpp", -- Adjust this to match your adapter name (`dap.adapters.<name>`)
				request = "attach",
				pid = require("dap.utils").pick_process,
				args = {},
			},
		}

		-- If you want to use this for Rust and C, add something like this:
		dap.configurations.c = dap.configurations.cpp
		dap.configurations.rust = dap.configurations.cpp

		-- use same configuration for javascript
		dap.configurations.javascript = dap.configurations.typescript

		local dapui = require("dapui")
		dap.listeners.after.event_initialized["dapui_config"] = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated["dapui_config"] = function()
			dapui.close()
		end
		dap.listeners.before.event_exited["dapui_config"] = function()
			dapui.close()
		end

		vim.fn.sign_define("DapBreakpoint", { text = "🟥", texthl = "", linehl = "", numhl = "" })
		vim.fn.sign_define("DapStopped", { text = "▶️", texthl = "", linehl = "", numhl = "" })

		vim.keymap.set("n", "<F5>", require("dap").continue)
		vim.keymap.set("n", "<F7>", require("dap").step_over)
		vim.keymap.set("n", "<F8>", require("dap").step_into)
		vim.keymap.set("n", "<F9>", require("dap").step_out)
		vim.keymap.set("n", "<F10>", function()
			dapui.close()
		end)
		vim.keymap.set("n", "<leader>b", require("dap").toggle_breakpoint)

		dapui.setup()
	end,
}
