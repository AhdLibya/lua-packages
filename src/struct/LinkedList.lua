--[[
	BY Ahdlibya
	2023
]]

-- Define the ListNode class
local ListNode = {}
ListNode.__index = ListNode

function ListNode.new(val)
	local node = {}
	setmetatable(node, ListNode)

	node.val = val
	node.next = nil

	return node
end


local LinkedList = {}
LinkedList.__index = LinkedList

function LinkedList.new()
	local list = {}
	setmetatable(list, LinkedList)

	list.head = nil
	list.tail = nil
	list.length = 0

	return list
end

function LinkedList:append(val)
	local node = ListNode.new(val)

	if self.head == nil then
		self.head = node
		self.tail = node
	else
		self.tail.next = node
		self.tail = node
	end

	self.length = self.length + 1
end

function LinkedList:prepend(val)
	local node = ListNode.new(val)

	if self.head == nil then
		self.head = node
		self.tail = node
	else
		node.next = self.head
		self.head = node
	end

	self.length = self.length + 1
end

function LinkedList:insert(val, idx)
	if idx < 1 or idx > self.length + 1 then
		error("Index out of range")
	end

	local node = ListNode.new(val)

	if idx == 1 then
		self:prepend(val)
	elseif idx == self.length + 1 then
		self:append(val)
	else
		local curr = self.head
		local prev = nil

		for _ = 1, idx - 1 do
			prev = curr
			curr = curr.next
		end

		prev.next = node
		node.next = curr

		self.length = self.length + 1
	end
end

function LinkedList:remove(val)
	local curr = self.head
	local prev = nil

	while curr ~= nil do
		if curr.val == val then
			if prev == nil then
				self.head = curr.next
			else
				prev.next = curr.next
			end

			if curr == self.tail then
				self.tail = prev
			end

			self.length = self.length - 1

			return true
		end

		prev = curr
		curr = curr.next
	end
	return false
end

function LinkedList:print()
	local curr = self.head

	while curr ~= nil do
		print(curr.val)
		curr = curr.next
	end
end

return LinkedList
