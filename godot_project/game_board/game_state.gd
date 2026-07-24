class_name GameState

var game_board_positions: Dictionary[Vector2i, Card] = {}
var card_states: Dictionary[Card, Dictionary]
var draw_pile: Array[Card] = []
var hand: Array[Card] = []
var discard_pile: Array[Card] = []


static func save(game_board: GameBoard):
	var state = new()
	state.game_board_positions = game_board.card_grid_spaces.duplicate()
	for card in state.game_board_positions.values():
		state.card_states[card] = card.save_state()
	state.draw_pile = game_board.player_cards.draw_pile.duplicate()
	for card in state.draw_pile:
		state.card_states[card] = card.save_state()
	state.hand = game_board.player_cards.hand.duplicate()
	for card in state.hand:
		state.card_states[card] = card.save_state()
	state.discard_pile = game_board.player_cards.discard_pile.duplicate()
	for card in state.discard_pile:
		state.card_states[card] = card.save_state()
	return state


func load(game_board: GameBoard):
	game_board.card_grid_spaces = game_board_positions.duplicate()
	for position in game_board_positions:
		var card = game_board_positions[position]
		card.load_state(card_states[card])
	game_board.player_cards.draw_pile = draw_pile.duplicate()
	for card in game_board.player_cards.draw_pile:
		card.load_state(card_states[card])
	game_board.player_cards.hand = hand.duplicate()
	for card in game_board.player_cards.hand:
		card.load_state(card_states[card])
	game_board.player_cards.discard_pile = discard_pile.duplicate()
	for card in game_board.player_cards.discard_pile:
		card.load_state(card_states[card])


func equals(state: GameState) -> bool:
	return (
		game_board_positions == state.game_board_positions
		and card_states == state.card_states
		and draw_pile == state.draw_pile
		and hand == state.hand
		and discard_pile == state.discard_pile
	)
