--[[
	BY Ahdlibya
	2023
]]


--[=[
		@class Queue
]=]
local Queue = {}
Queue.__index = Queue

--[=[
	@within Queue 
	```lua
	local Queue = require(PATH_TO_QUEUE_MODULE)
	local queue = Queue.new() -- new queue Instance
	```
	Construct a new Instance of The queue class
	@return Queue
]=]
function Queue.new()
	local queue = {}
	setmetatable(queue, Queue)

	queue.front = 0
	queue.back = -1
	queue.items = {}

	return queue
end
--[=[
	@within Queue 
	```lua
	local Queue = require(PATH_TO_QUEUE_MODULE)
	local queue = Queue.new()
	for i = 1, 10, 1 do
	    queue:enqueue(i)
		--queue -> {1, 2, 3, 4, etc...}
		--where's 1 is the first item in side the queue
	end
	```
	This function take one parameter and insert it at the end of the queue
	@param item  any
	@return any
]=]
function Queue:enqueue(item)
	self.back = self.back + 1
	self.items[self.back] = item
end
--[=[
	@within Queue 
	```lua
	local Queue = require(PATH_TO_QUEUE_MODULE)
	local queue = Queue.new()
	for i = 1, 10, 1 do
	    queue:enqueue(i)
	end
	while not queue:isEmpty() do
	    local val = queue:dequeue()
	    print(val) -- > 1 , 2 ,3 , etc...
	    task.wait(1)
	end
	```
	This function take no parameter and return the first queued item
	@return any
]=]
function Queue:dequeue()
	if self:isEmpty() then
		error("Queue is empty")
	end
	local item = self.items[self.front]
	self.items[self.front] = nil
	self.front = self.front + 1
	-- Reset the queue if it's empty
	if self.front > self.back then
		self.front = 0
		self.back = -1
	end
	return item
end

--[=[
	@within Queue 
	```lua
	local Queue = require(PATH_TO_QUEUE_MODULE)
	local queue = Queue.new()
	for i = 1, 10, 1 do
	    queue:enqueue(i)
	end
	local peek = queue:peek()
	print(peek) -- > 1
	```
	This function take no parameter and return the first queued item
	@return any
]=]
function Queue:peek()
	return self.items[self.front]
end

--[=[
	@within Queue 
	```lua
	local Queue = require(PATH_TO_QUEUE_MODULE)
	local queue = Queue.new()

	-- fill in the queue
	queue:enqueue(1)

	-- check if it's empty
	local isEmpty = queue:isEmpty()
	print(isEmpty) -- > false

	-- clear in the queue
	queue:dequeue()

	-- check if it's empty
	local isEmpty = queue:isEmpty()
	print(isEmpty) -- > true
	```
	@return boolean
]=]
function Queue:isEmpty()
	return self.front > self.back
end
--[=[
	@within Queue 
	```lua
	local Queue = require(PATH_TO_QUEUE_MODULE)
	local queue = Queue.new()
	for i = 1, 10, 1 do
	    queue:enqueue(i)
	end
	local size = queue:size()
	print(size) --> 10
	```
	return the number of items inside the queue
	@return number
]=]
function Queue:size()
	return self.back - self.front + 1
end

return Queue
