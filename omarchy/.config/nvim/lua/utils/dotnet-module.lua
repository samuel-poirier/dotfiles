local M = {}

M.ignored_solutions = {}

function M.get_qualified_test_name()
	local bufnr = vim.api.nvim_get_current_buf()
	local node = vim.treesitter.get_node()
	if not node then
		return nil
	end

	local method_name, class_name, namespace_name

	-- Walk up from cursor to find enclosing method, class, and namespace
	while node do
		local type = node:type()

		if type == "method_declaration" and not method_name then
			for child in node:iter_children() do
				if child:type() == "identifier" then
					method_name = vim.treesitter.get_node_text(child, bufnr)
					break
				end
			end
		elseif type == "class_declaration" and not class_name then
			for child in node:iter_children() do
				if child:type() == "identifier" then
					class_name = vim.treesitter.get_node_text(child, bufnr)
					break
				end
			end
		elseif
			(type == "namespace_declaration" or type == "file_scoped_namespace_declaration") and not namespace_name
		then
			for child in node:iter_children() do
				if child:type() == "qualified_name" or child:type() == "identifier" then
					namespace_name = vim.treesitter.get_node_text(child, bufnr)
					break
				end
			end
		end

		node = node:parent()
	end

	if not method_name then
		vim.notify("No test method found under cursor", vim.log.levels.WARN)
		return nil
	end

	local parts = {}
	if namespace_name then
		table.insert(parts, namespace_name)
	end
	if class_name then
		table.insert(parts, class_name)
	end
	table.insert(parts, method_name)

	return table.concat(parts, ".")
end

function M.run_in_terminal(cmd)
	vim.cmd("botright split | resize 15")
	vim.cmd("terminal " .. cmd)
	vim.cmd("startinsert")
end

function M.get_roslyn_sln()
	for _, client in ipairs(vim.lsp.get_clients({ name = "roslyn_ls" })) do
		-- root_dir is the closest fallback if no explicit tracking exists

		for entry, type in vim.fs.dir(client.root_dir) do
			if type == "file" and entry:match("%.slnx?$") and not vim.tbl_contains(M.ignored_solutions, entry) then
				return entry
			end
		end
	end
end

return M
