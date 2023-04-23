# 1.1.0 changes
- String values can now be chunked (similar to striping) across many databanks to allow for better databank load share and allows for much larger strings to be stored than before.
- Setting a value clears the key on all databanks due to how chunking is implemented.
- `raid.getNbKeys()` isn't the same as `#raid.getKeyList()` because chunking can create entries in many databanks. `#raid.getKeyList()` returns a set of all keys while `raid.getNbKeys()` doesn't respect the set and count *duplicate* keys.
- Moved library sourcecode to `libs` folder.

# 1.0.0
- Keys are distributed across multiple databanks.