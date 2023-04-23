-- This is just for Lua Language Server to define an interface.

---@class IStringChunker
---@field Chunk fun(str:string, maxChunks:integer):string[]
---@field Dechunk fun(chunks:string[]):string