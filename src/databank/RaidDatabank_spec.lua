local Raid = require("databank.RaidDatabank")
local UTF8Chunker = require("chunking.UTF8Chunker")

describe("raid.RaidDatabank", function()
    describe("New", function()
        it("rejects zero Databanks", function()
            local noHash = function(key) return 0 end

            assert.has.error(function() Raid.New({}, noHash) end, "Need at least one databank")
        end)
        it("rejects nil hash function", function()
            local bank1 = {}

            ---@diagnostic disable-next-line: param-type-mismatch
            assert.has.error(function() Raid.New({bank1}, nil) end, "Need a hash function")
        end)
        it("rejects duplicate Databanks", function()
            local noHash = function(key) return 0 end
            local bank1 = {}

            assert.has.error(function() Raid.New({ bank1, bank1 }, noHash) end, "Duplicate databank")
        end)
        it("rejects nil databanks", function()
            local noHash = function(key) return 0 end
            local bank1 = {}
            local bank2 = nil
            local bank3 = {}

            assert.has.error(function() Raid.New({ bank1, bank2, bank3 }, noHash) end, "nil databank 2")
        end)
        it("rejects nil databanks", function()
            local noHash = function(key) return 0 end
            local bank1 = nil
            local bank2 = {}
            local bank3 = {}

            assert.has.error(function() Raid.New({ bank1, bank2, bank3 }, noHash) end, "nil databank 1")
        end)
        it("treats all-nil databanks as no databanks", function()
            local noHash = function(key) return 0 end
            local bank1 = nil
            local bank2 = nil
            local bank3 = nil

            assert.has.error(function() Raid.New({ bank1, bank2, bank3 }, noHash) end, "Need at least one databank")
        end)
        it("doesn't account for trailing nil banks", function()
            local noHash = function(key) return 0 end
            local bank1 = {}
            local bank2 = nil -- trailing
            local bank3 = nil -- trailing

            local raid = Raid.New({ bank1, bank2, bank3 }, noHash)

            -- Note! If you happen to pass in nil banks at the end, they won't be added.
            -- If there is a case where a programming board would give a nil link to a Databank,
            -- such as at long distances, this might corrupt the raid!
            assert.are_same(1, raid.GetBankCount())
        end)
        it("accepts 1 Databank", function()
            local noHash = function(key) return 0 end
            local bank1 = {}

            local r = Raid.New({ bank1 }, noHash)

            assert.are_same(1, r.GetBankCount())
        end)
        it("accepts 10 Databanks", function()
            local noHash = function(key) return 0 end
            local bank1 = {}
            local bank2 = {}
            local bank3 = {}
            local bank4 = {}
            local bank5 = {}
            local bank6 = {}
            local bank7 = {}
            local bank8 = {}
            local bank9 = {}
            local bank10 = {}

            local raid = Raid.New({ bank1, bank2, bank3, bank4, bank5, bank6, bank7, bank8, bank9, bank10 }, noHash)

            assert.are_same(10, raid.GetBankCount())
        end)
    end)
    describe("clear", function()
        it("calls clear on all its banks", function()
            local noHash = function(key) return 0 end
            local bank1 = {}
            local bank2 = {}
            spy.on(bank1, "clear")
            spy.on(bank2, "clear")

            local raid = Raid.New({ bank1, bank2 }, noHash)
            raid.clear()

            assert.spy(bank1.clear).was_called(1)
            assert.spy(bank2.clear).was_called(1)
        end)
    end)
    describe("getNbKeys", function()
        it("calls getNbKeys on all its banks and sums them up", function()
            local noHash = function(key) return 0 end
            local bank1 = { getNbKeys = function() return 2 end }
            local bank2 = { getNbKeys = function() return 3 end }
            spy.on(bank1, "getNbKeys")
            spy.on(bank2, "getNbKeys")

            local raid = Raid.New({ bank1, bank2 }, noHash)
            local nbKeys = raid.getNbKeys()

            assert.are_same(5, nbKeys)
            assert.spy(bank1.getNbKeys).was_called(1)
            assert.spy(bank2.getNbKeys).was_called(1)
        end)
    end)
    describe("getKeyList", function()
        it("calls getKeyList on all its banks and concatenates their keys", function()
            local noHash = function(key) return 0 end
            local bank1 = { getKeyList = function() return { "a", "b" } end }
            local bank2 = { getKeyList = function() return { "c", "d", "e" } end }
            spy.on(bank1, "getKeyList")
            spy.on(bank2, "getKeyList")

            local raid = Raid.New({ bank1, bank2 }, noHash)
            local keyList = raid.getKeyList()

            assert.are_same({ "a", "b", "c", "d", "e" }, keyList)
            assert.spy(bank1.getKeyList).was_called(1)
            assert.spy(bank2.getKeyList).was_called(1)
        end)
        it("produces a set of keys if duplicate entries were found", function()
            local noHash = function(key) return 0 end
            local bank1 = { getKeyList = function() return { "a", "b", "dupe" } end }
            local bank2 = { getKeyList = function() return { "dupe", "c", "d" } end }

            local raid = Raid.New({ bank1, bank2 }, noHash)
            local keyList = raid.getKeyList()

            assert.are_same({ "a", "b", "dupe", "c", "d" }, keyList)
        end)
    end)
    describe("hasKey", function()
        it("calls hasKey on its respective bucket", function()
            local hash = spy.new(function(key) return 2 end) -- Fake hash, ought to match bank1
            local bank1 = { hasKey = function(key) return 1 end }
            local bank2 = { hasKey = function(key) return 0 end }
            spy.on(bank1, "hasKey")
            spy.on(bank2, "hasKey")

            local raid = Raid.New({ bank1, bank2 }, hash)
            local hasKey = raid.hasKey("key")

            assert.are_same(1, hasKey)
            assert.spy(hash).was_called_with("key")
            assert.spy(bank1.hasKey).was_called_with("key")
            assert.spy(bank2.hasKey).was_not_called()
        end)
    end)
    describe("clearValue", function()
        it("calls clearValue on all buckets", function()
            local noHash = spy.new(function(key) return 0 end)
            local bank1 = { clearValue = function(key) return 1 end } -- Assume this databank has the key
            local bank2 = { clearValue = function(key) return 0 end } -- Assume this databank doesnt
            spy.on(bank1, "clearValue")
            spy.on(bank2, "clearValue")

            local raid = Raid.New({ bank1, bank2 }, noHash)
            local success = raid.clearValue("key")

            assert.are_same(1, success)
            assert.spy(noHash).was_not_called()
            assert.spy(bank1.clearValue).was_called_with("key")
            assert.spy(bank2.clearValue).was_called_with("key")
        end)
    end)
    describe("setStringValue", function()
        it("calls setStringValue on its respective bucket", function()
            local hash = spy.new(function(key) return 3 end) -- Fake hash, ought to match bank2
            local bank1 = { setStringValue = function(key, val) end, clearValue = function(key) return 0 end }
            local bank2 = { setStringValue = function(key, val) end, clearValue = function(key) return 0 end }
            spy.on(bank1, "setStringValue")
            spy.on(bank2, "setStringValue")
            spy.on(bank1, "clearValue")
            spy.on(bank2, "clearValue")

            -- Retaining version 1.0.0 behavior apart from calling clearValue prior to setting
            -- a value when no chunker is specified in Raid.New
            local raid = Raid.New({ bank1, bank2 }, hash)
            raid.setStringValue("key", "value")

            assert.spy(hash).was_called_with("key")
            assert.spy(bank1.clearValue).was_called(1)
            assert.spy(bank2.clearValue).was_called(1)
            assert.spy(bank1.setStringValue).was_not_called()
            assert.spy(bank2.setStringValue).was_called_with("key", "value")
        end)
        it("calls setStringValue on all buckets using a UTF8Chunker", function()
            local hash = spy.new(function(key) return 3 end) -- Fake hash, ought to match bank2
            local bank1 = { setStringValue = function(key, val) end, clearValue = function(key) return 0 end }
            local bank2 = { setStringValue = function(key, val) end, clearValue = function(key) return 0 end }
            spy.on(bank1, "setStringValue")
            spy.on(bank2, "setStringValue")
            spy.on(bank1, "clearValue")
            spy.on(bank2, "clearValue")

            local raid = Raid.New({ bank1, bank2 }, hash, UTF8Chunker.New(1))
            raid.setStringValue("key", "value")

            assert.spy(hash).was_called_with("key")
            assert.spy(bank1.clearValue).was_called(1)
            assert.spy(bank2.clearValue).was_called(1)
            assert.spy(bank1.setStringValue).was_called_with("key", "ue")
            assert.spy(bank2.setStringValue).was_called_with("key", "val")
        end)
    end)
    describe("getStringValue", function()
        it("calls getStringValue on all its buckets", function()
            local hash = spy.new(function(key) return 3 end) -- Fake hash, ought to match bank2
            local bank1 = { getStringValue = function(key) return "" end } -- If the key doesn't exist, databanks return ""
            local bank2 = { getStringValue = function(key) return "bank2 value" end }
            spy.on(bank1, "getStringValue")
            spy.on(bank2, "getStringValue")

            local raid = Raid.New({ bank1, bank2 }, hash)
            local value = raid.getStringValue("key")

            assert.are_same("bank2 value", value)
            assert.spy(hash).was_called_with("key")
            assert.spy(bank1.getStringValue).was_called_with("key")
            assert.spy(bank2.getStringValue).was_called_with("key")
        end)
        it("concatenates chunks from all buckets", function()
            local hash = spy.new(function(key) return 3 end) -- Fake hash, ought to match bank2
            local bank1 = { getStringValue = function(key) return "ue" end } -- last chunk
            local bank2 = { getStringValue = function(key) return "val" end } -- first chunk
            spy.on(bank1, "getStringValue")
            spy.on(bank2, "getStringValue")

            local raid = Raid.New({ bank1, bank2 }, hash)
            local value = raid.getStringValue("key")

            assert.are_same("value", value)
            assert.spy(hash).was_called_with("key")
            assert.spy(bank1.getStringValue).was_called_with("key")
            assert.spy(bank2.getStringValue).was_called_with("key")
        end)
    end)
    describe("setIntValue", function()
        it("calls setIntValue on its respective bucket", function()
            local hash = spy.new(function(key) return 3 end) -- Fake hash, ought to match bank2
            local bank1 = { setIntValue = function(key, val) end, clearValue = function(key) return 0 end }
            local bank2 = { setIntValue = function(key, val) end, clearValue = function(key) return 0 end }
            spy.on(bank1, "setIntValue")
            spy.on(bank2, "setIntValue")
            spy.on(bank1, "clearValue")
            spy.on(bank2, "clearValue")

            local raid = Raid.New({ bank1, bank2 }, hash)
            raid.setIntValue("key", 2)

            assert.spy(hash).was_called_with("key")
            assert.spy(bank1.clearValue).was_called(1)
            assert.spy(bank2.clearValue).was_called(1)
            assert.spy(bank1.setIntValue).was_not_called()
            assert.spy(bank2.setIntValue).was_called_with("key", 2)
        end)
    end)
    describe("getIntValue", function()
        it("calls getIntValue on its respective bucket", function()
            local hash = spy.new(function(key) return 3 end) -- Fake hash, ought to match bank2
            local bank1 = { getIntValue = function(key) return 1 end }
            local bank2 = { getIntValue = function(key) return 2 end }
            spy.on(bank1, "getIntValue")
            spy.on(bank2, "getIntValue")

            local raid = Raid.New({ bank1, bank2 }, hash)
            local value = raid.getIntValue("key")

            assert.are_same(2, value)
            assert.spy(hash).was_called_with("key")
            assert.spy(bank1.getIntValue).was_not_called()
            assert.spy(bank2.getIntValue).was_called_with("key")
        end)
    end)
    describe("setFloatValue", function()
        it("calls setFloatValue on its respective bucket", function()
            local hash = spy.new(function(key) return 3 end) -- Fake hash, ought to match bank2
            local bank1 = { setFloatValue = function(key, val) end, clearValue = function(key) return 0 end }
            local bank2 = { setFloatValue = function(key, val) end, clearValue = function(key) return 0 end }
            spy.on(bank1, "setFloatValue")
            spy.on(bank2, "setFloatValue")
            spy.on(bank1, "clearValue")
            spy.on(bank2, "clearValue")

            local raid = Raid.New({ bank1, bank2 }, hash)
            raid.setFloatValue("key", 2.2)

            assert.spy(hash).was_called_with("key")
            assert.spy(bank1.clearValue).was_called(1)
            assert.spy(bank2.clearValue).was_called(1)
            assert.spy(bank1.setFloatValue).was_not_called()
            assert.spy(bank2.setFloatValue).was_called_with("key", 2.2)
        end)
    end)
    describe("getFloatValue", function()
        it("calls getFloatValue on its respective bucket", function()
            local hash = spy.new(function(key) return 3 end) -- Fake hash, ought to match bank2
            local bank1 = { getFloatValue = function(key) return 1.1 end }
            local bank2 = { getFloatValue = function(key) return 2.2 end }
            spy.on(bank1, "getFloatValue")
            spy.on(bank2, "getFloatValue")

            local raid = Raid.New({ bank1, bank2 }, hash)
            local value = raid.getFloatValue("key")

            assert.are_same(2.2, value)
            assert.spy(hash).was_called_with("key")
            assert.spy(bank1.getFloatValue).was_not_called()
            assert.spy(bank2.getFloatValue).was_called_with("key")
        end)
    end)
    describe("hash caching", function()
        it("only calls the hash function once for several requests of the same key", function()
            local hash = spy.new(function(key) return 3 end) -- Fake hash, ought to match bank2
            local bank1 = { getFloatValue = function(key) return 1.1 end }
            local bank2 = { getFloatValue = function(key) return 2.2 end }
            spy.on(bank1, "getFloatValue")
            spy.on(bank2, "getFloatValue")

            local raid = Raid.New({ bank1, bank2 }, hash)
            raid.getFloatValue("key") -- value not important
            raid.getFloatValue("key") -- value not important
            raid.getFloatValue("key") -- value not important

            assert.spy(hash).was_called(1)
            assert.spy(bank1.getFloatValue).was_not_called()
            assert.spy(bank2.getFloatValue).was_called(3)
        end)
    end)
end)