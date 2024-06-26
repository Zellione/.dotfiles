return {
    "rcarriga/nvim-dap-ui",
    dependencies = {
        "mfussenegger/nvim-dap",
        "nvim-neotest/nvim-nio"
    },
    config = function()
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
        vim.keymap.set("n", "<F10>", require("dap").step_over)
        vim.keymap.set("n", "<F11>", require("dap").step_into)
        vim.keymap.set("n", "<F12>", require("dap").step_out)
        vim.keymap.set("n", "<leader>b", require("dap").toggle_breakpoint)

        dapui.setup()
    end,
}
