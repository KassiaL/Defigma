local M = {}

local function table_to_vec4(c)
	return vmath.vector4(c.r, c.g, c.b, c.a)
end

function M.apply_all(gradients)
	for k, v in pairs(gradients) do
		M.apply(k, gradients)
	end
end

function M.apply_all_transform(gradients)
	for k, v in pairs(gradients) do
		M.apply_transform(k)
	end
end

function M.apply(node_name, gradients)
	local g = gradients[node_name]

	local node = gui.get_node(node_name)
	gui.set(node, "gradient_stop0", table_to_vec4(g.stops[1].color))
	gui.set(node, "gradient_stop1", table_to_vec4(g.stops[2].color))
	local gradient_data = g.data

	if g.type == "radial" then
		gui.set(node, "grad_data", vmath.vector4(gradient_data[1].x, 1 - gradient_data[1].y, gradient_data[2].x, gradient_data[2].y))
		gui.set(node, "grad_data2", vmath.vector4((gradient_data[3]) / 180 * math.pi, 0, 0, 0))
	elseif g.type == "linear" then
		gui.set(node, "grad_data", vmath.vector4(gradient_data[1].x, 1 - gradient_data[1].y, gradient_data[2].x, 1 - gradient_data[2].y))
	end
	M.apply_transform(node_name)
end

function M.apply_transform(node_name)
	local node = gui.get_node(node_name)

	local scale = gui.get_scale(node)
	local size = gui.get_size(node)

	local gui_width = gui.get_width()
	local gui_height = gui.get_height()
	local width, height = window.get_size()
	local ratio
	if gui_height > gui_width then
		local standart_ratio = gui_width / gui_height
		ratio = width / height

		if ratio > standart_ratio then
			ratio = height / gui_height
		else
			ratio = width / gui_width
		end
	else
		local standart_ratio = gui_height / gui_width
		ratio = height / width

		if ratio < standart_ratio then
			ratio = height / gui_height
		else
			ratio = width / gui_width
		end
	end

	local image_atlas_size = vmath.vector3(ratio * size.x * scale.x, ratio * size.y * scale.y, 0)
	local pos_left_down = gui.get_screen_position(node)
	pos_left_down.x = pos_left_down.x - image_atlas_size.x / 2
	pos_left_down.y = pos_left_down.y - image_atlas_size.y / 2
	gui.set(node, hash("node_transform"), vmath.vector4(pos_left_down.x, pos_left_down.y, image_atlas_size.x, image_atlas_size.y))
	gui.set(node, hash("node_scale"), vmath.vector4(scale.x, scale.y, 0, 0))
end

return M
