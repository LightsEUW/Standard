extends RefCounted


func run() -> Array[String]:
	var failures: Array[String] = []

	var status := StatusComponent.new()

	if not status.has_flag(DefenseEnums.BuildingStatus.ACTIVE):
		failures.append("StatusComponent should start as ACTIVE by default")

	status.set_flag(DefenseEnums.BuildingStatus.NO_POWER, true)
	status.set_flag(DefenseEnums.BuildingStatus.DAMAGED, true)
	if not status.has_flag(DefenseEnums.BuildingStatus.NO_POWER):
		failures.append("NO_POWER flag should be set")
	if not status.has_flag(DefenseEnums.BuildingStatus.DAMAGED):
		failures.append("DAMAGED flag should coexist with NO_POWER")
	if not status.has_flag(DefenseEnums.BuildingStatus.ACTIVE):
		failures.append("ACTIVE flag should be unaffected by setting other flags")

	status.set_flag(DefenseEnums.BuildingStatus.NO_POWER, false)
	if status.has_flag(DefenseEnums.BuildingStatus.NO_POWER):
		failures.append("NO_POWER flag should clear")
	if not status.has_flag(DefenseEnums.BuildingStatus.DAMAGED):
		failures.append("clearing NO_POWER should not affect DAMAGED")

	var names: Array[String] = status.get_active_flag_names()
	if not names.has("DAMAGED"):
		failures.append("get_active_flag_names should include DAMAGED")
	if names.has("NO_POWER"):
		failures.append("get_active_flag_names should not include cleared NO_POWER")

	return failures
