---@class RaidDatabank
local RaidDatabank = {}

---@class NoChunker : IStringChunker
local NoChunker = {}

function NoChunker.Chunk(str, maxChunks)
    return { str }
end

function NoChunker.Dechunk(chunks)
    return table.concat(chunks)
end

---@alias KeyHashingFunction fun(str:string):integer

---Facilitates larger storage by splitting keys over multiple databanks using a hashing function.<br>
--- - Once a Raid has been used, its databank order or instances should not be allowed to change.<br>
--- - If you need to resize or reorder the databanks in the raid, pull all data to RAM, clear all keys, 
---   create your new Raid setup and set the values again. Note that there is no way to tell which type 
---   of data is stored in the databanks.
--- - Do not change hashing function after a raid setup has been used.
---@param databanks Databank[] List of databanks, at least one. Should always be the same for a setup and never change.
---@param hash KeyHashingFunction Key hashing function.
---@param chunker IStringChunker? Optional string chunker
---@return RaidDatabankObject instance An object that mimics Databank functionality
function RaidDatabank.New(databanks, hash, chunker)
    assert(#databanks > 0, "Need at least one databank")
    assert(hash, "Need a hash function")
    for i = 1, #databanks do
        assert(databanks[i], "nil databank " .. i)
        for j = i + 1, #databanks do
            assert(databanks[i] ~= databanks[j], "Duplicate databank")
        end
    end

    chunker = chunker or NoChunker

    ---@type { [string]: integer }
    local cache = {}

    local function bucketIndex(key, offset)
        cache[key] = cache[key] or (hash(key) % #databanks)
        return (cache[key] + offset - 1) % #databanks + 1
    end

    local function bucket(key, offset)
        return databanks[bucketIndex(key, offset or 1)]
    end

    ---@class RaidDatabankObject
    local raid = {}

    ---This function exists for testing purposes.<br>
    ---Client code should generally not need to call this.
    ---@return integer count Number of databanks in this RaidDatabank
    function raid.GetBankCount()
        return #databanks
    end

    ---Clear the RaidDatabank
    function raid.clear()
        for _, bank in ipairs(databanks) do
            bank.clear()
        end
    end

    ---Returns the total number of keys that are stored inside the RaidDatabank.<br>
    ---Note, if the `chunker` create several chunks for a string then `raid.getNbKeys()`<br>
    ---will give a different result than `#raid.getKeyList()` because it is accounting<br>
    ---for all those chunked entries as well.
    ---@return integer nbKeys The number of keys
    function raid.getNbKeys()
        local nbKeys = 0
        for _, bank in ipairs(databanks) do
            nbKeys = nbKeys + bank.getNbKeys()
        end
        return nbKeys
    end

    ---Returns all the keys in the RaidDatabank
    ---@return string[] keys The key list, as a list of string
    function raid.getKeyList()
        local keys = {}
        local registeredKey = {}
        for _, bank in ipairs(databanks) do
            for _, key in ipairs(bank.getKeyList()) do
                if not registeredKey[key] then
                    table.insert(keys, key)
                    registeredKey[key] = true
                end
            end
        end
        return keys
    end

    ---Returns 1 if the key is present in the RaidDatabank, 0 otherwise
    ---@param key string The key used to store a value
    ---@return integer hasKey 1 if the key exists and 0 otherwise
    function raid.hasKey(key)
        return bucket(key).hasKey(key)
    end

    ---Remove the given key if the key is present in the RaidDatabank
    ---@param key string The key used to store a value
    ---@return integer success 1 if the key has been successfully removed, 0 otherwise
    function raid.clearValue(key)
        local successes = 0
        for i = 1, #databanks do
            successes = successes + databanks[i].clearValue(key)
        end
        return successes > 0 and 1 or 0
    end

    ---Stores a string value at the given key in the RaidDatabank
    ---@param key string The key used to store the value
    ---@param val string The value, as a string
    function raid.setStringValue(key, val)
        -- Since we dont know how many chunks a previous call made, 
        -- it needs to clear the key across all buckets
        raid.clearValue(key)
        local chunks = chunker.Chunk(val, #databanks)
        for i = 1, #chunks do
            bucket(key, i).setStringValue(key, chunks[i])
        end
    end

    ---Returns value stored in the given key as a string of the RaidDatabank
    ---@param key string The key used to retrieve the value
    ---@return string value The value as a string
    function raid.getStringValue(key)
        local values = {}
        for i = 1, #databanks do
            table.insert(values, bucket(key, i).getStringValue(key))
        end
        return chunker.Dechunk(values)
    end

    ---Stores an integer value at the given key in the RaidDatabank
    ---@param key string The key used to store the value
    ---@param val integer The value, as an integer
    function raid.setIntValue(key, val)
        -- Since we dont know if a string was using this key before 
        -- it needs to clear the key across all buckets
        raid.clearValue(key)
        bucket(key).setIntValue(key, val)
    end

    ---Returns value stored in the given key as an integer of the RaidDatabank
    ---@param key string The key used to retrieve the value
    ---@return integer value The value as an integer
    function raid.getIntValue(key)
        return bucket(key).getIntValue(key)
    end

    ---Stores a floating number value at the given key in the RaidDatabank
    ---@param key string The key used to store the value
    ---@param val number The value, as a floating number
    function raid.setFloatValue(key, val)
        -- Since we dont know if a string was using this key before 
        -- it needs to clear the key across all buckets
        raid.clearValue(key)
        bucket(key).setFloatValue(key, val)
    end

    ---Returns value stored in the given key as a floating number of the RaidDatabank
    ---@param key string The key used to retrieve the value
    ---@return number value The value as a floating number
    function raid.getFloatValue(key)
        return bucket(key).getFloatValue(key)
    end

    return raid
end

return RaidDatabank