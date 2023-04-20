---@class RaidDatabank
local RaidDatabank = {}

---@alias KeyHashingFunction fun(str:string):integer

---Facilitates larger storage by splitting keys over multiple databanks using a hashing function.<br>
--- - Once a Raid has been used, its databank order or instances should not be allowed to change.<br>
--- - If you need to resize or reorder the databanks in the raid, pull all data to RAM, clear all keys, 
---   create your new Raid setup and set the values again. Note that there is no way to tell which type 
---   of data is stored in the databanks.
--- - Do not change hashing function after a raid setup has been used.
---@param databanks Databank[] List of databanks, at least one. Should always be the same for a setup and never change.
---@param hash KeyHashingFunction Key hashing function.
---@return RaidDatabankObject instance An object that mimics Databank functionality
function RaidDatabank.New(databanks, hash)
    assert(#databanks > 0, "Need at least one databank")
    for i = 1, #databanks do
        assert(databanks[i], "nil databank " .. i)
        for j = i + 1, #databanks do
            assert(databanks[i] ~= databanks[j], "Duplicate databank")
        end
    end    

    ---@type { [string]: integer }
    local cache = {}
    local function bucket(key)
        cache[key] = cache[key] or (hash(key) % #databanks) + 1
        return databanks[cache[key]]
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

    ---Returns the number of keys that are stored inside the RaidDatabank
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
        for _, bank in ipairs(databanks) do
            for _, key in ipairs(bank.getKeyList()) do
                table.insert(keys, key)
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
        return bucket(key).clearValue(key)
    end

    ---Stores a string value at the given key in the RaidDatabank
    ---@param key string The key used to store the value
    ---@param val string The value, as a string
    function raid.setStringValue(key, val)
        bucket(key).setStringValue(key, val)
    end

    ---Returns value stored in the given key as a string of the RaidDatabank
    ---@param key string The key used to retrieve the value
    ---@return string value The value as a string
    function raid.getStringValue(key)
        return bucket(key).getStringValue(key)
    end

    ---Stores an integer value at the given key in the RaidDatabank
    ---@param key string The key used to store the value
    ---@param val integer The value, as an integer
    function raid.setIntValue(key, val)
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