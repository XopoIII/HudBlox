--!strict
--- Independent token leases and legacy reason bits. No services or shared owner names.
const ControlHolds = {}
export type Book = { leases: { [() -> ()]: string }, bits: { [string]: true } }
function ControlHolds.new(): Book
	return { leases = {}, bits = {} }
end
function ControlHolds.hold(book: Book, reason: string, changed: () -> ()): () -> ()
	local live = true
	const function release()
		if not live then
			return
		end
		live = false
		book.leases[release] = nil
		changed()
	end
	book.leases[release] = reason
	changed()
	return release
end
function ControlHolds.set(book: Book, reason: string, hide: boolean)
	book.bits[reason] = if hide then true else nil
end
function ControlHolds.active(book: Book): boolean
	return next(book.leases) ~= nil or next(book.bits) ~= nil
end
function ControlHolds.wants(book: Book, touch: boolean, pad: boolean): (boolean, boolean)
	const leases = next(book.leases) ~= nil
	const bits = next(book.bits) ~= nil
	return leases or (bits and (touch or pad)), touch and (leases or bits)
end
return ControlHolds
