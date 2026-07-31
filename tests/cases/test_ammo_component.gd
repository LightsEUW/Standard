extends RefCounted


func run() -> Array[String]:
	var failures: Array[String] = []

	var ammo := AmmoComponent.new()
	ammo.setup("test_rounds", 3, 2.0)

	if not ammo.try_consume(1):
		failures.append("try_consume should succeed while ammo remains")
	if ammo.current_ammo != 2:
		failures.append("expected 2 ammo remaining, got %d" % ammo.current_ammo)

	ammo.try_consume(1)
	ammo.try_consume(1) # depletes to 0, should start reloading
	if not ammo.is_reloading():
		failures.append("ammo should start reloading once depleted")
	if ammo.try_consume(1):
		failures.append("try_consume should fail while reloading")

	ammo._process(2.1) # simulate reload_time elapsing
	if ammo.is_reloading():
		failures.append("ammo should finish reloading after reload_time elapses")
	if ammo.current_ammo != 3:
		failures.append("expected full magazine (3) after reload, got %d" % ammo.current_ammo)

	var unlimited := AmmoComponent.new()
	unlimited.setup("", 0, 0.0)
	if not unlimited.try_consume(1):
		failures.append("capacity=0 (e.g. energy weapons) should always be able to fire")

	return failures
