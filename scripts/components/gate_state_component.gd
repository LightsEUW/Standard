## Gate state machine (open/closed/opening/closing/blocked/destroyed).
## Needs power to actively open/close, but requires no power to simply stay
## closed. Building-specific triggers (friendly-unit detection, enemy alarm)
## live in AutomaticGate.gd and just call request_open()/request_close().
class_name GateStateComponent
extends Node

signal state_changed(new_state: DefenseEnums.GateState)

var state: DefenseEnums.GateState = DefenseEnums.GateState.CLOSED
var open_close_duration: float = 1.0

var _elapsed: float = 0.0
var _power: PowerConsumerComponent = null


func setup(p_open_close_duration: float, power: PowerConsumerComponent) -> void:
	open_close_duration = p_open_close_duration
	_power = power


func is_blocking() -> bool:
	return state in [DefenseEnums.GateState.CLOSED, DefenseEnums.GateState.OPENING, DefenseEnums.GateState.BLOCKED, DefenseEnums.GateState.DESTROYED]


func request_open() -> void:
	if state == DefenseEnums.GateState.DESTROYED or state == DefenseEnums.GateState.BLOCKED:
		return
	if not _has_power():
		return
	if state == DefenseEnums.GateState.OPEN or state == DefenseEnums.GateState.OPENING:
		return
	_set_state(DefenseEnums.GateState.OPENING)
	_elapsed = 0.0


func request_close() -> void:
	if state == DefenseEnums.GateState.DESTROYED or state == DefenseEnums.GateState.BLOCKED:
		return
	if state == DefenseEnums.GateState.CLOSED or state == DefenseEnums.GateState.CLOSING:
		return
	if not _has_power():
		# No power: gates fail safe by simply staying/going closed instantly.
		_set_state(DefenseEnums.GateState.CLOSED)
		return
	_set_state(DefenseEnums.GateState.CLOSING)
	_elapsed = 0.0


func mark_blocked(blocked: bool) -> void:
	if state == DefenseEnums.GateState.DESTROYED:
		return
	if blocked:
		_set_state(DefenseEnums.GateState.BLOCKED)
	elif state == DefenseEnums.GateState.BLOCKED:
		_set_state(DefenseEnums.GateState.CLOSED)


func mark_destroyed() -> void:
	_set_state(DefenseEnums.GateState.DESTROYED)


func _has_power() -> bool:
	return _power == null or _power.poll_power()


func _process(delta: float) -> void:
	if state != DefenseEnums.GateState.OPENING and state != DefenseEnums.GateState.CLOSING:
		return
	_elapsed += delta
	if _elapsed >= open_close_duration:
		_set_state(DefenseEnums.GateState.OPEN if state == DefenseEnums.GateState.OPENING else DefenseEnums.GateState.CLOSED)


func _set_state(new_state: DefenseEnums.GateState) -> void:
	if state == new_state:
		return
	state = new_state
	state_changed.emit(state)
