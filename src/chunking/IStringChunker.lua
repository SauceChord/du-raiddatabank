-- This is just for Lua Language Server to define an interface.

---@class IStringChunker
local IStringChunker = {}

---@param str string
---@param maxChunks integer
---@return string[] 
function IStringChunker.Chunk(str, maxChunks) return {} end

---@param chunks string[]
---@return string
function IStringChunker.Dechunk(chunks) return '' end