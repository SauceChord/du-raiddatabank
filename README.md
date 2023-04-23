# Raid for Databank in Dual Universe

Contains:

- A logged databank decorator for demo/debugging
- A raid databank composite
- A string hashing function
- A rather messy example (improvements appreciated)

Depends on [DU-LuaC](https://github.com/wolfe-labs/DU-LuaC) to build example.

Type annotations were made for [lua-language-server](https://marketplace.visualstudio.com/items?itemName=sumneko.lua) for Visual Studio Code

# Unit tests are executed with [busted](https://lunarmodules.github.io/busted/)

- Windows users may have to install luarocks/busted via [scoop.sh](https://scoop.sh/) ([see install steps](https://github.com/lunarmodules/busted/issues/715#issuecomment-1506833858))
- Run `busted` in project root directory

# Setup of [example.lua](https://github.com/SauceChord/du-raiddatabank/blob/4ff52eb5e4a2ee441e751e010d0875dc42c181b7/src/example.lua)

- Place a Programming Board
- Place 8 Databanks
- Rename the Databanks to Raid1/8 to Raid8/8
- Link Raid Databanks to Programming Board
- Run `du-lua build` to build the project
- Copy contents from `out/release/example.json`
- Right click programming board, select *Advanced/Paste Lua configuration from clipboard*
- Activate programming board
- Look in Lua log window

# Minimal code example of setting up raid with chunking:

```lua
local Hash = require("hash:FNV1A32")
local Chunker = require("chunking:UTF8Chunker")
local Raid = require("databank:RaidDatabank")

-- Assume databank1 and databank2 are slots of your 
-- programming board and that their order never changes
-- then this makes a two-databank raid
local raid = Raid.New({ databank1, databank2 }, Hash, Chunker.New(50))

-- Use raid like you would use a databank but with less
-- functions than the original, such as getClass et.c.
if raid.getStringValue("setup") ~= "done" then
    system.print("has not done setup")
    raid.setStringValue("setup", "done")
end

unit.exit()
```
