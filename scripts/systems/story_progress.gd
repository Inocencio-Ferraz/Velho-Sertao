extends Node

signal state_changed(new_state: int)

enum State {
	INTRO,
	PADRE_CONVERSOU,
	PRIMEIRO_POCO,
	PRIMEIRO_POCO_SECO,
	SEGUNDO_POCO,
	SEGUNDO_POCO_SECO,
	TERCEIRO_POCO,
	TERCEIRO_POCO_CONCLUIDO
}

var current_state: State = State.INTRO

func mark_priest_conversation_finished() -> void:
	_advance_to(State.PADRE_CONVERSOU)

func begin_first_well_encounter() -> void:
	_advance_to(State.PRIMEIRO_POCO)

func complete_first_well() -> void:
	_advance_to(State.PRIMEIRO_POCO_SECO)

func begin_second_well_encounter() -> void:
	_advance_to(State.SEGUNDO_POCO)

func complete_second_well() -> void:
	_advance_to(State.SEGUNDO_POCO_SECO)

func begin_third_well_encounter() -> void:
	_advance_to(State.TERCEIRO_POCO)

func complete_third_well() -> void:
	_advance_to(State.TERCEIRO_POCO_CONCLUIDO)

func _advance_to(next_state: State) -> void:
	if next_state <= current_state:
		return
	current_state = next_state
	state_changed.emit(current_state)
