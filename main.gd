extends Control
const Model = preload("res://model.gd")
const INK = Color("29263d")
const CREAM = Color("fff2d9")
const CORAL = Color("eb7867")
const GOLD = Color("f8bb72")
const MUTED = Color("a39ab0")
const CARD = Color("3b334f")
const SAVE_PATH = "user://night_market.cfg"
var model = Model.new()
var stage := "title"
var tutorial_page := 0
var prices := [2, 2, 2]
var stocks := [6, 6, 5]
var wrap: VBoxContainer
var scroll: ScrollContainer
var seed_edit: LineEdit
var price_labels: Array = []
var stock_labels: Array = []
var click_sound: AudioStreamPlayer

func _ready() -> void:
	var game_theme := Theme.new()
	game_theme.default_font = load("res://assets/NotoSansKR.ttf")
	game_theme.default_font_size = 19
	theme = game_theme
	model.reset(20261028, false)
	click_sound = AudioStreamPlayer.new()
	click_sound.stream = load("res://assets/tick.wav")
	add_child(click_sound)
	set_process_input(true)
	get_viewport().size_changed.connect(_on_resize)
	_render()

func _draw() -> void:
	var sz := size
	draw_rect(Rect2(Vector2.ZERO, sz), Color("211f37"))
	for i in 11:
		var x: float = sz.x * float(i) / 10.0
		draw_line(Vector2(x, 0), Vector2(x - 75, sz.y), Color("34304c", 0.32), 1)
	for i in 8:
		var y: float = sz.y * float(i) / 7.0
		draw_line(Vector2(0, y), Vector2(sz.x, y), Color("53435b", 0.18), 1)
	for i in 15:
		var px: float = fmod(float(i * 197 + 37), maxf(sz.x, 1.0))
		var py: float = fmod(float(i * 139 + 101), maxf(sz.y, 1.0))
		draw_circle(Vector2(px, py), 2.0, Color("f7cc86", 0.4))

func _on_resize() -> void:
	if is_instance_valid(scroll):
		wrap.custom_minimum_size.x = minf(760, maxf(280, size.x - 28))
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER and not (get_viewport().gui_get_focus_owner() is LineEdit):
			if stage == "morning": _open_shop()
			elif stage == "result": _next_day()
			elif stage == "tutorial": _next_tutorial()
		elif event.keycode == KEY_ESCAPE and stage != "title":
			stage = "title"
			_render()
		elif stage == "morning" and event.keycode >= KEY_1 and event.keycode <= KEY_3:
			_change(int(event.keycode - KEY_1), 0, 1)
		elif stage == "morning" and event.keycode >= KEY_4 and event.keycode <= KEY_6:
			_change(int(event.keycode - KEY_4), 1, 1)

func _style(color: Color, border: Color = Color.TRANSPARENT, radius: int = 18) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(radius)
	s.set_border_width_all(2 if border.a > 0 else 0)
	s.border_color = border
	s.content_margin_left = 16
	s.content_margin_right = 16
	s.content_margin_top = 12
	s.content_margin_bottom = 12
	return s

func _panel(color: Color = CARD, border: Color = Color("716076")) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", _style(color, border))
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return p

func _label(text: String, font_size: int = 19, color: Color = CREAM) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l

func _button(text: String, callback: Callable, primary: bool = false) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(52, 52)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_color_override("font_color", INK if primary else CREAM)
	b.add_theme_color_override("font_hover_color", INK)
	b.add_theme_color_override("font_focus_color", INK)
	b.add_theme_font_size_override("font_size", 18)
	b.add_theme_stylebox_override("normal", _style(GOLD if primary else Color("51425d")))
	b.add_theme_stylebox_override("hover", _style(Color("ffe1a6")))
	b.add_theme_stylebox_override("pressed", _style(CORAL))
	b.add_theme_stylebox_override("focus", _style(Color.TRANSPARENT, GOLD))
	b.pressed.connect(func() -> void:
		click_sound.play()
		callback.call()
	)
	return b

func _step_button(text: String, callback: Callable) -> Button:
	var b := _button(text, callback)
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	b.custom_minimum_size = Vector2(54, 52)
	return b

func _row() -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 8)
	return h

func _gap(height: float = 8.0) -> void:
	var c := Control.new()
	c.custom_minimum_size.y = height
	wrap.add_child(c)

func _render() -> void:
	for child in get_children():
		if child != click_sound:
			remove_child(child)
			child.queue_free()
	scroll = ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(center)
	wrap = VBoxContainer.new()
	wrap.custom_minimum_size.x = minf(760, maxf(280, size.x - 28))
	wrap.add_theme_constant_override("separation", 12)
	center.add_child(wrap)
	_gap(14)
	var top := _row()
	wrap.add_child(top)
	var brand := _label("●  달밤 상회  /  NIGHT MARKET", 17, GOLD)
	brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(brand)
	var nights := _label("07 NIGHTS", 15, MUTED)
	nights.custom_minimum_size.x = 90
	nights.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	top.add_child(nights)
	var picture := TextureRect.new()
	picture.texture = load("res://assets/market.svg")
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.custom_minimum_size.y = 115 if size.x < 520 else 208
	wrap.add_child(picture)
	match stage:
		"title": _title()
		"tutorial": _tutorial()
		"morning": _morning()
		"result": _result()
		"ending": _ending()
	_gap(16)
	wrap.add_child(_label("직접 제작한 벡터 삽화 · 정수 수요 모형 · 현실 경제 예측 아님", 13, MUTED))
	_gap(20)

func _title() -> void:
	wrap.add_child(_label("야시장 가격표", 42, CREAM))
	wrap.add_child(_label("일곱 밤 동안 가격과 재고를 고르고, 손님이 남긴 숫자를 읽으세요.", 19, MUTED))
	var intro := _panel()
	wrap.add_child(intro)
	var v := VBoxContainer.new()
	intro.add_child(v)
	v.add_child(_label("오늘의 규칙", 23, GOLD))
	v.add_child(_label("3가지 먹거리  ·  가격 1~5  ·  재고 0~8\n수요는 가격과 매일의 사건에 따라 움직입니다.\n7일 순이익 75 이상, 누적 폐기 15 이하가 목표입니다.", 18))
	wrap.add_child(_button("처음부터 배우기  →", func(): tutorial_page = 0; stage = "tutorial"; _render(), true))
	wrap.add_child(_button("고정 캠페인 시작", func(): _start(20261028, false)))
	var replay_panel := _panel(Color("302b43"))
	wrap.add_child(replay_panel)
	var replay_box := VBoxContainer.new()
	replay_panel.add_child(replay_box)
	replay_box.add_child(_label("다른 밤, 같은 규칙  /  시드 반복", 17, GOLD))
	seed_edit = LineEdit.new()
	seed_edit.text = "271828"
	seed_edit.placeholder_text = "숫자 시드"
	seed_edit.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
	seed_edit.custom_minimum_size.y = 48
	replay_box.add_child(seed_edit)
	replay_box.add_child(_button("시드로 시작", func(): _start(int(seed_edit.text) if seed_edit.text.is_valid_int() else 271828, true)))
	var save := ConfigFile.new()
	if save.load(SAVE_PATH) == OK and str(save.get_value("run", "stage", "")) in ["morning", "result"]:
		wrap.add_child(_button("저장된 밤 이어하기", _resume, true))

func _tutorial() -> void:
	var headings := ["01 / 가격은 손님의 발걸음", "02 / 재고는 내일로 가지 않아요", "03 / 저녁 장부를 읽는 법"]
	var bodies := ["각 먹거리의 가격은 1~5입니다. 싸면 더 많이 찾지만 한 개당 수입은 적습니다. 비싸면 손님이 돌아설 수 있어요.", "아침마다 0~8개를 준비합니다. 재고 한 개의 원가는 2냥. 팔리지 않은 것은 버려지고 폐기에 기록됩니다.", "저녁에는 기준 수요 + 사건 변화 + 가격 효과를 따로 보여줍니다. 순이익 = 매출 − 준비 원가. 7일간 순이익 75 이상, 폐기 15 이하를 함께 달성하세요."]
	wrap.add_child(_label("상인 수첩  %d / 3" % [tutorial_page + 1], 18, GOLD))
	var p := _panel()
	wrap.add_child(p)
	var v := VBoxContainer.new()
	p.add_child(v)
	v.add_theme_constant_override("separation", 22)
	v.add_child(_label(headings[tutorial_page], 28))
	v.add_child(_label(bodies[tutorial_page], 21, CREAM))
	v.add_child(_label("●  ●  ●".substr(0, 3 + tutorial_page * 3), 24, CORAL))
	wrap.add_child(_button("장사 시작  →" if tutorial_page == 2 else "다음 쪽  →", _next_tutorial, true))
	wrap.add_child(_button("첫 화면으로", func(): stage = "title"; _render()))

func _next_tutorial() -> void:
	if tutorial_page < 2:
		tutorial_page += 1
		_render()
	else: _start(20261028, false)

func _start(new_seed: int, is_replay: bool) -> void:
	model.reset(new_seed, is_replay)
	prices = [2, 2, 2]
	stocks = [6, 6, 5]
	stage = "morning"
	_save()
	_render()

func _header() -> void:
	var p := _panel(Color("493b54"), CORAL)
	wrap.add_child(p)
	var v := VBoxContainer.new()
	p.add_child(v)
	v.add_child(_label("%s  ·  %d / 7일" % ["시드 %d" % model.seed if model.replay else "고정 캠페인", model.day], 16, GOLD))
	v.add_child(_label("순이익 %d / 75냥     폐기 %d / 15개" % [model.profit, model.waste], 22))

func _morning() -> void:
	_header()
	wrap.add_child(_label("아침의 가격표", 32))
	wrap.add_child(_label("오늘의 사건  ◇  " + Model.EVENTS[model.event_index()], 19, GOLD))
	wrap.add_child(_label("가격·재고를 정하세요. + / − 버튼을 탭하거나 Tab으로 이동해 Enter로 선택할 수 있습니다.", 16, MUTED))
	price_labels = []
	stock_labels = []
	for i in 3:
		var p := _panel(CARD, Color("695b76"))
		wrap.add_child(p)
		var v := VBoxContainer.new()
		v.add_theme_constant_override("separation", 8)
		p.add_child(v)
		v.add_child(_label(["●  01  /  달빛 꼬치", "●  02  /  꿀밤 호떡", "●  03  /  별빛 차"][i], 22, GOLD))
		var price_row := _row()
		v.add_child(price_row)
		var price_name := _label("가격", 17)
		price_name.custom_minimum_size.x = 50
		price_name.autowrap_mode = TextServer.AUTOWRAP_OFF
		price_row.add_child(price_name)
		price_row.add_child(_step_button("−", _change.bind(i, 0, -1)))
		var price_label := _label("%d냥" % prices[i], 23)
		price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		price_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		price_row.add_child(price_label)
		price_labels.append(price_label)
		price_row.add_child(_step_button("+", _change.bind(i, 0, 1)))
		var stock_row := _row()
		v.add_child(stock_row)
		var stock_name := _label("재고", 17)
		stock_name.custom_minimum_size.x = 50
		stock_name.autowrap_mode = TextServer.AUTOWRAP_OFF
		stock_row.add_child(stock_name)
		stock_row.add_child(_step_button("−", _change.bind(i, 1, -1)))
		var stock_label := _label("%d개" % stocks[i], 23)
		stock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		stock_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		stock_row.add_child(stock_label)
		stock_labels.append(stock_label)
		stock_row.add_child(_step_button("+", _change.bind(i, 1, 1)))
	wrap.add_child(_button("영업 시작  /  오늘의 장부 보기  →", _open_shop, true))
	wrap.add_child(_button("첫 화면으로  (진행 저장)", func(): _save(); stage = "title"; _render()))

func _change(i: int, field: int, amount: int) -> void:
	if field == 0:
		prices[i] = clampi(prices[i] + amount, 1, 5)
		price_labels[i].text = "%d냥" % prices[i]
	else:
		stocks[i] = clampi(stocks[i] + amount, 0, 8)
		stock_labels[i].text = "%d개" % stocks[i]
	_save()

func _open_shop() -> void:
	if stage != "morning": return
	model.trade(prices, stocks)
	stage = "ending" if model.failed() or model.won() else "result"
	_save()
	_render()

func _result() -> void:
	_header()
	wrap.add_child(_label("밤의 장부", 32))
	wrap.add_child(_label(Model.EVENTS[model.event_index()] + "  ·  기준 수요에서 사건 효과와 가격 효과를 반영했습니다.", 17, GOLD))
	_results()
	wrap.add_child(_button("다음 날 아침  →", _next_day, true))
	wrap.add_child(_button("첫 화면으로  (진행 저장)", func(): _save(); stage = "title"; _render()))

func _results() -> void:
	for row in model.last:
		var p := _panel()
		wrap.add_child(p)
		var v := VBoxContainer.new()
		p.add_child(v)
		v.add_child(_label(row.name + "  /  %d냥 × %d개" % [row.price, row.sold], 21, GOLD))
		v.add_child(_label("수요 %d = 기준 %d %s%d(사건) %s%d(가격)" % [row.demand, row.base, "+" if row.event >= 0 else "", row.event, "+" if row.elastic >= 0 else "", row.elastic], 16))
		v.add_child(_label("준비 %d  ·  판매 %d  ·  폐기 %d   |   매출 %d − 원가 %d = 순이익 %d" % [row.stock, row.sold, row.waste, row.revenue, row.stock * 2, row.net], 16, CREAM))

func _next_day() -> void:
	if stage != "result": return
	model.advance()
	stage = "morning"
	_save()
	_render()

func _ending() -> void:
	_header()
	wrap.add_child(_label("완판의 밤!" if model.won() else "다음 장을 준비해요", 36, GOLD if model.won() else CORAL))
	wrap.add_child(_label("일곱 밤의 목표를 모두 달성했습니다." if model.won() else "목표: 순이익 75냥 이상과 폐기 15개 이하. 다시 가격과 준비량을 조율해 보세요.", 18))
	_results()
	wrap.add_child(_button("같은 시드로 다시 도전", func(): _start(model.seed, model.replay), true))
	wrap.add_child(_button("첫 화면으로", func(): stage = "title"; _render()))

func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("run", "stage", stage)
	cfg.set_value("run", "seed", model.seed)
	cfg.set_value("run", "replay", model.replay)
	cfg.set_value("run", "day", model.day)
	cfg.set_value("run", "profit", model.profit)
	cfg.set_value("run", "waste", model.waste)
	cfg.set_value("run", "prices", prices)
	cfg.set_value("run", "stocks", stocks)
	cfg.set_value("run", "last", model.last)
	cfg.save(SAVE_PATH)

func _resume() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK: return
	model.reset(int(cfg.get_value("run", "seed", 20261028)), bool(cfg.get_value("run", "replay", false)))
	model.day = clampi(int(cfg.get_value("run", "day", 1)), 1, 7)
	model.profit = int(cfg.get_value("run", "profit", 0))
	model.waste = int(cfg.get_value("run", "waste", 0))
	model.last = cfg.get_value("run", "last", [])
	prices = cfg.get_value("run", "prices", [2, 2, 2])
	stocks = cfg.get_value("run", "stocks", [6, 6, 5])
	stage = str(cfg.get_value("run", "stage", "morning"))
	_render()
