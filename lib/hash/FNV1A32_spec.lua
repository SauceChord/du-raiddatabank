local hash = require("libs.hash.FNV1A32")

-- Most expected values have been lifted from https://md5calc.com/hash using the FNV1A32 Algorithm
describe("hash.FNV1A32", function()
    it("has some sort of undefined error on nil", function()
        ---@diagnostic disable-next-line: param-type-mismatch
        assert.has.error(function() hash(nil) end)
    end)
    it("hashes '' to 811c9dc5", function()
        assert.are_same(0x811c9dc5, hash(''))
    end)
    it("hashes 'Test' to 2ffcbe05", function()
        assert.are_same(0x2ffcbe05, hash('Test'))
    end)
    it("hashes 'Bärry?' to 160dbfb6", function() -- Utf-8 character 'ä'
        assert.are_same(0x160dbfb6, hash('Bärry?'))
    end)
    it("hashes 'A really long string with no interesting content!' to 3eca023f", function()
        assert.are_same(0x3eca023f, hash('A really long string with no interesting content!'))
    end)
end)
