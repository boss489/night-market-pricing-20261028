extends SceneTree
func _initialize() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game._start(12345, true)
	assert(game.stage == "morning")
	game._change(0, 0, 1)
	assert(game.prices[0] == 3)
	game._open_shop()
	assert(game.stage == "result")
	assert(game.model.last.size() == 3)
	var net = game.model.profit
	game.stage = "title"
	game._resume()
	assert(game.stage == "result" and game.model.profit == net and game.prices[0] == 3)
	game._next_day()
	assert(game.stage == "morning" and game.model.day == 2)
	game._start(20261028, false)
	for d in 7:
		game.prices = [3, 3, 3]
		game.stocks = [6, 5, 4]
		game._open_shop()
		if d < 6: game._next_day()
	assert(game.stage == "ending" and game.model.won())
	game._start(game.model.seed, false)
	assert(game.stage == "morning" and game.model.day == 1 and game.model.profit == 0)
	game.queue_free()
	print("SCENE_TEST_PASS controls, trade, save/resume, seven-day ending, restart")
	quit()
