extends RefCounted
const NAMES = ["달빛 꼬치", "꿀밤 호떡", "별빛 차"]
const BASE = [7, 6, 5]
const EVENTS = ["비가 내리는 저녁", "거리 공연의 밤", "조용한 골목", "축제의 불빛", "선선한 바람"]
var seed: int = 20261028
var replay: bool = false
var day: int = 1
var profit: int = 0
var waste: int = 0
var last: Array = []
func reset(new_seed: int, is_replay: bool) -> void:
	seed = absi(new_seed)
	replay = is_replay
	day = 1
	profit = 0
	waste = 0
	last = []
static func elasticity(price: int) -> int:
	return [0, 2, 1, 0, -2, -4][clampi(price, 1, 5)]
func event_index() -> int:
	return int((seed * 17 + day * 13) % EVENTS.size())
func event_effect(product: int) -> int:
	var table = [[-1, 0, 1], [1, 1, 0], [0, -1, 0], [1, 0, 1], [0, 1, -1]]
	return table[event_index()][product]
func base_demand(product: int) -> int:
	return BASE[product] + int((seed % 11 + day * 7 + product * 5) % 3) - 1
func demand_at(product: int, price: int) -> int:
	return maxi(0, base_demand(product) + event_effect(product) + elasticity(price))
func trade(prices: Array, stocks: Array) -> Array:
	last = []
	for i in 3:
		var price: int = clampi(int(prices[i]), 1, 5)
		var stock: int = clampi(int(stocks[i]), 0, 8)
		var demand: int = demand_at(i, price)
		var sold: int = mini(stock, demand)
		var leftover: int = stock - sold
		var revenue: int = sold * price
		var net: int = revenue - stock * 2
		profit += net
		waste += leftover
		last.append({"name": NAMES[i], "price": price, "stock": stock, "base": base_demand(i), "event": event_effect(i), "elastic": elasticity(price), "demand": demand, "sold": sold, "waste": leftover, "revenue": revenue, "net": net})
	return last.duplicate(true)
func advance() -> void:
	day = mini(7, day + 1)
func failed() -> bool:
	return profit <= -16 or (day == 7 and not last.is_empty() and not won())
func won() -> bool:
	return day == 7 and not last.is_empty() and profit >= 75 and waste <= 15
