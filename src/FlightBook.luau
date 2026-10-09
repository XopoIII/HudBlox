--!strict
--- A reward flight's bookkeeping as plain data: the list of what is in the air, walked once a
--- frame, and the pools of what has flown and can fly again. No Instance is touched here, so every
--- rule is specified without Roblox; `Flight` keeps its flights and its icon frames by it.
const FlightBook = {}

--- Spent things kept to be used again, a pool for every key.
export type Pools<K, T> = { [K]: { T } }

--> Steps every item of `list` that is not spent, and drops the spent ones from it.
--> `step` may add to the end of `list` and may spend any item, its own or another's: what it adds
--> is stepped in the same walk, and what it spends is not stepped again. It must not take
--> anything out of `list` itself: only the walk does, so no item is skipped or dropped unspent.
--> The order of the items between each other is not kept.
function FlightBook.walk<T>(list: { T }, spent: (item: T) -> boolean, step: (item: T) -> ())
	local at = 1
	while at <= #list do
		const item = list[at]
		if not spent(item) then
			step(item)
		end
		if spent(item) then
			-- Out by swap. The length is read after the step, which may have added to the list,
			-- and the item swapped in is looked at next, in this same place.
			const last = #list
			list[at] = list[last]
			list[last] = nil
		else
			at += 1
		end
	end
end

--> A spent item of `key`'s pool, the last one given, or nil when the pool has none.
function FlightBook.take<K, T>(pools: Pools<K, T>, key: K): T?
	const pool = pools[key]
	if pool == nil then
		return nil
	end
	return table.remove(pool)
end

--> Puts `item` into `key`'s pool. True when that made the pool, which is when the caller starts
--> to watch for the key's end, to `drop` it.
function FlightBook.give<K, T>(pools: Pools<K, T>, key: K, item: T): boolean
	const pool = pools[key]
	if pool == nil then
		pools[key] = { item }
		return true
	end
	table.insert(pool, item)
	return false
end

--> Forgets `key`'s pool and everything in it.
function FlightBook.drop<K, T>(pools: Pools<K, T>, key: K)
	pools[key] = nil
end

return FlightBook
