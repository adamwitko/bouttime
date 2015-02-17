exports = exports ? this
exports.GameStateMixin = 
	getInitialState: () ->
    gameState: exports.wftda.functions.camelize(this.props)

  getTeamState: (teamType) ->
    switch teamType
      when 'away' then this.state.gameState.awayAttributes
      when 'home' then this.state.gameState.homeAttributes

  getJamState: (teamType, jamIndex) ->
    this.getTeamState(teamType).jamStates[jamIndex]

  getPassState: (teamType, jamIndex, passIndex) ->
    this.getJamState(teamType, jamIndex).passStates[passIndex]