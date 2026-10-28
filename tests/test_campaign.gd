extends SceneTree
const Model = preload("res://model.gd")
func _initialize() -> void:
	var m = Model.new()
	m.reset(20261028, false)
	for d in 7:
		var rows = m.trade([3, 3, 3], [6, 5, 4])
		for r in rows:
			assert(r.sold + r.waste == r.stock)
			assert(r.stock <= 8 and r.demand >= 0)
		if d < 6: m.advance()
	assert(m.won())
	var font = load("res://assets/NotoSansKR.ttf")
	var missing := ""
	for char_string in "야시장 가격표 달빛 꼬치 꿀밤 호떡 별빛 차 영업 순이익 폐기 수요 사건 성공 실패 저장 재시작 − ◇ ● → × ·":
		if not font.has_char(char_string.unicode_at(0)):
			missing += char_string
	if missing != "":
		printerr("Missing glyphs: " + missing)
		quit(1)
		return
	print("CAMPAIGN_TEST_PASS seven-day victory: profit=%d waste=%d; Korean UI glyphs present" % [m.profit, m.waste])
	quit()
