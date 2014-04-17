function euclidianDistance(x,w)
	local dist = 0
	if(w == nil) then return -1 end
	if (#x ~= #w) then error("dimension of input mismatch, expected:"..#w.." got:"..#x) end
	for i,v in pairs(x) do
		dist = dist + (x[i]-w[i])^2
	end
	return math.sqrt(dist)
end

function pNormDistance(x,w,p)
	local dist = 0
	f(w == nil) then return -1 end
	if (#x ~= #w) then error("dimension of input mismatch, expected:"..#w.." got:"..#x) end
	for i,v in pairs(x) do
		dist = dist + (x[i]-w[i])^p
	end
	return dist^(1/p)
end
function minDist(resTable,net)
	local d = nil
	local winner = nil
	for _,v in pairs(resTable) do
		if ((d == nil or d > v[2]) and (v[2] ~= -1)) then
			d = v[2]
			winner = v[1]
		end
	end
	if(winner ~= nil and d > net[winner].radius) then 
		winner = nil 
		d = 0
	end
	return (winner or 'vigilance'),d
end

function trainning(trainSet,network,alpha,cons)
	local res = {}
	local maxD = 0
	local winner = -1
	for k,v in pairs(trainSet) do
		res = runOnce(v,network)
		winner,d = minDist(res,network)
		if (winner == 'vigilance') then
			table.insert(network,createNeuron(0.7,2,v))
		else
			for i,_ in ipairs(network[winner].w) do
				network[winner].w[i] = network[winner].w[i] + alpha*(v[i]-network[winner].w[i])
			end
		end
	end
end
function runOnce(input,network)
	local activationTable = {}
	for id,neuron in pairs(network) do
		table.insert(activationTable,{id,euclidianDistance(input,neuron.w)})
	end
	return activationTable
end
function runNetwork(input,network)
	local activationTable = {}
	for i,x in ipairs(input) do
		for id,neuron in pairs(network) do
			table.insert(activationTable,{i,id,euclidianDistance(x,neuron.w)})
		end
	end
	return activationTable
end
function printNetwork(net)
	print("-------net print---------")
	local str = ""
	for k,v in pairs(net) do
	str = ""
		print("neuron: "..k)
		print("  radius: "..v.radius)
		if v.radius == 0 then
				str = "vigilance"
		else
			for i,j in pairs(v.w) do
				str = str..j..","
			end
		end
		print("  w     : "..str)
	end
	print("-------------------------")
end
function createNetwork()
	local network = {}
	network.vigilance = {radius = 0, w = nil}
	return network
end
function createNeuron(radius,dim,center)
	local w = {}
	print(center[1],center[2])
	if center~= nil then
		if (#center ~= dim) then error("dimension mismatch creating neuron") end
		for _,v in ipairs(center) do
			table.insert(w,v)
		end
	else
		for k = 1,dim do	
			table.insert(w,(math.random()*2)-1)
		end
	end
	local neuron = {radius = radius, w = w}
	return neuron
end

-- usage example

local inputs = {}
local benchmark = {}
local net = createNetwork()
inputs = {{0.1,1},{-1,-1},{0.2,0},{0,0},{0.3,-0.1}}
res = trainning(inputs,net,0.1,false)
printNetwork(net)
local f = io.open('res_art_lua.csv','w')
for id,neuron in pairs(net) do
	if id~='vigilance' then
	f:write(id..";"..neuron.radius..";"..neuron.w[1]..";"..neuron.w[2].."\n")
	end
end
f:close()