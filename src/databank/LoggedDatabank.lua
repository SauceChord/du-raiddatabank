local json = require("dkjson")

---@class LoggedDatabank
local LoggedDatabank = {}

---Decorates a databank (subset of functions) by logging function calls, keys, values and databank name.
---@param databank Databank
---@param logger fun(msg:string)
---@return LoggedDatabankInstance
function LoggedDatabank.Wrap(databank, logger)
    ---@class LoggedDatabankInstance
    local logged = {}

    ---Clear the Databank
    function logged.clear()
        logger(string.format("clearing databank '%s'", databank.getName()))
    end

    ---Returns the number of keys that are stored inside the Databank
    ---@return integer nbKeys The number of keys
    function logged.getNbKeys()
        local nbKeys = databank.getNbKeys()
        logger(string.format("getNbKeys databank '%s' : %d", databank.getName(), nbKeys))
        return nbKeys
    end

    ---Returns all the keys in the Databank
    ---@return string[] keys The key list, as a list of string
    function logged.getKeyList()
        local keyList = databank.getKeyList()
        logger(string.format("getKeyList databank '%s' : %d", databank.getName(), json.encode(keyList)))
        return keyList
    end

    ---Returns 1 if the key is present in the Databank, 0 otherwise
    ---@param key string The key used to store a value
    ---@return integer hasKey 1 if the key exists and 0 otherwise
    function logged.hasKey(key)
        local hasKey = databank.hasKey(key)
        logger(string.format("hasKey(%s) databank '%s' : %d", key, databank.getName(), hasKey))
        return hasKey
    end

    ---Remove the given key if the key is present in the Databank
    ---@param key string The key used to store a value
    ---@return integer success 1 if the key has been successfully removed, 0 otherwise
    function logged.clearValue(key)
        local clearValue = databank.clearValue(key)
        logger(string.format("clearValue(%s) databank '%s' : %d", key, databank.getName(), clearValue))
        return clearValue
    end

    ---Stores a string value at the given key in the Databank
    ---@param key string The key used to store the value
    ---@param val string The value, as a string
    function logged.setStringValue(key, val)
        databank.setStringValue(key, val)
        logger(string.format("setStringValue(%s, %s) databank '%s'", key, val, databank.getName()))
    end

    ---Returns value stored in the given key as a string of the Databank
    ---@param key string The key used to retrieve the value
    ---@return string value The value as a string
    function logged.getStringValue(key)
        local value = databank.getStringValue(key)
        logger(string.format("getStringValue(%s) databank '%s' : %s", key, databank.getName(), value))
        return value
    end

    ---Stores an integer value at the given key in the Databank
    ---@param key string The key used to store the value
    ---@param val integer The value, as an integer
    function logged.setIntValue(key, val)
        databank.setIntValue(key, val)
        logger(string.format("setIntValue(%s, %d) databank '%s'", key, val, databank.getName()))
    end

    ---Returns value stored in the given key as an integer of the Databank
    ---@param key string The key used to retrieve the value
    ---@return integer value The value as an integer
    function logged.getIntValue(key)
        local value = databank.getIntValue(key)
        logger(string.format("getIntValue(%s) databank '%s' : %d", key, databank.getName(), value))
        return value
    end

    ---Stores a floating number value at the given key in the Databank
    ---@param key string The key used to store the value
    ---@param val number The value, as a floating number
    function logged.setFloatValue(key, val)
        databank.setFloatValue(key, val)
        logger(string.format("setFloatValue(%s, %f) databank '%s'", key, val, databank.getName()))
    end

    ---Returns value stored in the given key as a floating number of the Databank
    ---@param key string The key used to retrieve the value
    ---@return number value The value as a floating number
    function logged.getFloatValue(key)
        local value = databank.getFloatValue(key)
        logger(string.format("getFloatValue(%s) databank '%s' : %f", key, databank.getName(), value))
        return value
    end

    return logged
end

return LoggedDatabank