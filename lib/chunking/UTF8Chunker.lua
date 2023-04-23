---@class UTF8Chunker
local UTF8Chunker = {}

function UTF8Chunker.New(minimumLength)
    assert(minimumLength >= 1, "minimum length must be 1 or greater")

    ---@class UTF8ChunkerInstance : IStringChunker
    local chunker = {}

    ---Returns the minimum UTF-8 string length that `Chunk` will utilize, as passed through `New`
    ---@return integer minimumLength
    function chunker.GetMinimumLength()
        return minimumLength
    end

    ---@param str string A UTF-8 string to chunk into roughly even string lengths (variable length characters)
    ---@param maxChunks integer Maximum number of chunks to return
    ---@return string[] chunks An array (of length 1 to `maxChunks`) of string chunks of `str`, of roughly equal string length
    function chunker.Chunk(str, maxChunks)
        if str == '' then return { '' } end
        local resultChunks = {}
        local utf8StringLength = utf8.len(str, 1, #str)
        local utf8ChunkLength = math.max(math.ceil(utf8StringLength / maxChunks), minimumLength)
        local utf8CharsProcessed = 0
        local strStartIndex = 1
        while strStartIndex <= #str do
            local utf8CharsToGo = utf8StringLength - utf8CharsProcessed
            local utf8CharsToRead = math.min(utf8CharsToGo, utf8ChunkLength)
            local strEndIndex = utf8.offset(str, utf8CharsToRead + 1, strStartIndex) - 1
            local chunk = str:sub(strStartIndex, strEndIndex)
            table.insert(resultChunks, chunk)
            strStartIndex = strEndIndex + 1
            utf8CharsProcessed = utf8CharsProcessed + utf8ChunkLength
        end
        return resultChunks
    end

    ---@param chunks string[] A list of chunk strings produced by `Chunk`
    ---@return string result A concatenated string of chunks
    function chunker.Dechunk(chunks)
        return table.concat(chunks)
    end

    return chunker
end

return UTF8Chunker
