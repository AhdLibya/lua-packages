--[[
	BY Ahdlibya
	2023
]]

type callback = (node: table) ->()

-- Define the TreeNode class
local TreeNode = {}
TreeNode.__index = TreeNode

function TreeNode.new(val)
	local node = {}
	setmetatable(node, TreeNode)

	node.val = val
	node.left = nil
	node.right = nil

	return node
end

-- Define the Tree class
local Tree = {}
Tree.__index = Tree

function Tree.new()
	local tree = {}
	setmetatable(tree, Tree)
	tree.root = nil
	return tree
end

function Tree:insert(val)
	if self.root == nil then
		self.root = TreeNode.new(val)
	else
		self:_insert(val, self.root)
	end
end

function Tree:_insert(val, node)
	if val < node.val then
		if node.left == nil then
			node.left = TreeNode.new(val)
		else
			self:_insert(val, node.left)
		end
	else
		if node.right == nil then
			node.right = TreeNode.new(val)
		else
			self:_insert(val, node.right)
		end
	end
end

function Tree:preorder(fn: callback)
	self:_preorder(self.root , fn)
end

function Tree:_preorder(node , fn: callback)
	if node ~= nil then
		fn(node)
		self:_preorder(node.left)
		self:_preorder(node.right)
	end
end

function Tree:inorder(fn)
	self:_inorder(self.root,fn)
end

function Tree:_inorder(node,fn: callback)
	if node ~= nil then
		self:_inorder(node.left)
		fn(node)
		self:_inorder(node.right)
	end
end

function Tree:postorder(fn: callback)
	self:_postorder(self.root,fn)
end

function Tree:_postorder(node , fn: callback)
	if node ~= nil then
		self:_postorder(node.left)
		self:_postorder(node.right)
		fn(node.val)
	end
end

function Tree:print()
	self:_inorder(self.root , print)
end

return Tree
