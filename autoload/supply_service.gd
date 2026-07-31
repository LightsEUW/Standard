## Stub logistics/resupply service. Instantly grants whatever ammo/material
## is requested today; a real supply-line system later only needs to change
## how/when it calls back, not the AmmoComponent contract that calls it.
extends Node

signal resupply_requested(requester: Node, resource_type: String, amount: int)


func request_resupply(requester: Node, resource_type: String, amount: int) -> void:
	resupply_requested.emit(requester, resource_type, amount)
