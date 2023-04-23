---Logs function calls to a Databank (for demo/debugging purposes)
---@type LoggedDatabank
local LoggedDatabank = require("databank:LoggedDatabank")

---An algorithm that computes a 32 bit hash for a string
---@type fun(str:string):integer
local Hasher = require("hash:FNV1A32")

---Chunks strings up in pieces
---@type UTF8Chunker
local Chunker = require("chunking:UTF8Chunker")

---Spreads out data over many databanks by hashing keys
---@type RaidDatabank
local RaidDatabank = require("databank:RaidDatabank")

-- Connect up to 10 empty DataBankUnits to this programming board.
-- I recommend setting up a naming of each DataBankUnit in build mode.
-- I use ELEMENT names (not link names) Raid1/8 through Raid8/8 in my own test (8 databanks)
-- This is preferred since many PBs can then easily link to the same Raid setup.
--
-- Please don't rename the databanks or add new ones after it has been setup once, 
-- or you won't find your data.
local databanks = library.getLinksByClass('DataBankUnit', true)
-- Sort them by name, or the order will be arbitrary which won't work for the raid setup.
table.sort(databanks, function(a, b) return a.getName() < b.getName() end)

-- For demo purposes, hook up LoggedDatabank wrapper to showcase which Databank is accessed
---@type LoggedDatabankInstance[]
local loggedDatabanks = {}
for i, databank in ipairs(databanks) do
  loggedDatabanks[i] = LoggedDatabank.Wrap(databank, system.print)
end

-- Just to show what a logged databank does (see Lua message tab)
loggedDatabanks[5].setIntValue("Gone", 10)
loggedDatabanks[5].clearValue("Gone")

-- Create a raid of logged databanks.
-- Strings get chunked if they are longer than 50 characters.
local raid = RaidDatabank.New(loggedDatabanks, Hasher, Chunker.New(50))

-- Demo some load balancing of databank usage
raid.hasKey("Foo") -- Outputs: hasKey(Foo) databank 'Raid8/8' : 0
raid.hasKey("Bar") -- Outputs: hasKey(Bar) databank 'Raid3/8' : 0
raid.hasKey("Data_" .. math.random(500)) -- Who knows which databank it'll choose?

-- Demo storing and retrieving a 80000 character string
if 0 == raid.hasKey("largeString") then
  raid.setStringValue("largeString", string.rep("x", 80000))
end
assert(raid.getStringValue("largeString") == string.rep("x", 80000))

-- Demo: Update the value of "Dots". In my example it is stored in Raid2/8
local dots = raid.getStringValue("Dots") .. "." -- Add a . to the string
if #dots >= 8 then dots = "" end                -- But don't let it get too big
raid.setStringValue("Dots", dots)               -- Save the updated value

unit.exit()
