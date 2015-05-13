React = require 'react/addons'
AppDispatcher = require '../dispatcher/app_dispatcher.coffee'
constants = require '../constants.coffee'
{ActionTypes} = require '../constants.coffee'
functions = require '../functions.coffee'
JamAndPeriodNumbers = require './jam_timer/jam_and_period_numbers.cjsx'
JTClocks = require './jam_timer/jt_clocks.cjsx'
Clocks = require '../clock.coffee'
TimeoutBars = require './jam_timer/timeout_bars.cjsx'
cx = React.addons.classSet
module.exports = React.createClass
  displayName: 'JamTimer'
  propTypes:
    periodClock: React.PropTypes.instanceOf(Clocks.Clock)
    jamClock: React.PropTypes.instanceOf(Clocks.Clock)
    jamNumber: React.PropTypes.number
    periodNumber: React.PropTypes.number
    gameStateId: React.PropTypes.string
    state: React.PropTypes.oneOf ["jam", "lineup", "timeout", "pregame", "halftime", "unofficial_final", "final"]
    home: React.PropTypes.shape
      hasOfficialReview: React.PropTypes.bool
      officialReviewsRetained: React.PropTypes.number
      isTakingOfficialReview: React.PropTypes.bool
      isTakingTimeout: React.PropTypes.bool
      timeouts: React.PropTypes.number
      initials: React.PropTypes.string
    away: React.PropTypes.shape
      hasOfficialReview: React.PropTypes.bool
      officialReviewsRetained: React.PropTypes.number
      isTakingOfficialReview: React.PropTypes.bool
      isTakingTimeout: React.PropTypes.bool
      timeouts: React.PropTypes.number
      initials: React.PropTypes.string
  getInitialState: () ->
    modalHandler: () ->
  shouldComponentUpdate: (nprops, nstate) ->
    true
  componentDidMount: () ->
    @props.jamClock.emitter.addListener "clockExpiration", @jamClockExpired
  componentWillUnmount: () ->
    @props.jamClock.emitter.removeListener "clockExpiration", @jamClockExpired
  jamClockExpired: () ->
    AppDispatcher.dispatchAndEmit
      type: ActionTypes.HANDLE_CLOCK_EXPIRATION
      gameId: @props.gameStateId
  handleToggleTimeoutBar: (evt) ->
    $target = $(evt.target)
    $parent = $target.closest(".timeout-bars").first()
    if $target.hasClass "official-review"
      if $target.hasClass "inactive"
        #Set has official review to true
        #Increment official reviews retained
        if $parent.hasClass "home"
          @restoreHomeTeamOfficialReview()
        else
          @restoreAwayTeamOfficialReview()
      else
        #Set has official review to false
        if $parent.hasClass "home"
          @removeHomeTeamOfficialReview()
        else
          @removeAwayTeamOfficialReview()
    else #Its a normal timeout not an official review
      timeoutsRemaining = 0
      if $target.hasClass "inactive"
        timeoutsRemaining = timeoutsRemaining + 1
      timeoutsRemaining = timeoutsRemaining + $target.nextAll(".bar").length
      #Set remaining timeouts
      if $parent.hasClass "home"
        @setHomeTeamTimeouts(timeoutsRemaining)
      else
        @setAwayTeamTimeouts(timeoutsRemaining)
    return null
  openModal: () ->
    $modal = $(@refs.modal.getDOMNode())
    $modal.modal('show')
  handleModal: () ->
    $modal = $(@refs.modal.getDOMNode())
    $input = $(@refs.modalInput.getDOMNode())
    $modal.modal('hide')
    val = parseInt($input.val())
    @state.modalHandler(val)
  clickJamEdit: () ->
    $input = $(@refs.modalInput.getDOMNode())
    $input.val(@props.jamNumber)
    @openModal()
    @setState
      modalHandler: @setJamNumber
  clickPeriodEdit: () ->
    $input = $(@refs.modalInput.getDOMNode())
    $input.val(@props.periodNumber)
    @openModal()
    @setState
      modalHandler: @setPeriodNumber
  clickJamClockEdit: () ->
    $input = $(@refs.modalInput.getDOMNode())
    $input.val(@props.jamClock.time/1000)
    @openModal()
    @setState
      modalHandler: @setJamClock
  clickPeriodClockEdit: () ->
    $input = $(@refs.modalInput.getDOMNode())
    $input.val(@props.periodClock.time/1000)
    @openModal()
    @setState
      modalHandler: @setPeriodClock
  startClock: () ->
    AppDispatcher.dispatchAndEmit
      type: ActionTypes.START_CLOCK
      gameId: @props.gameStateId
  stopClock: () ->
    AppDispatcher.dispatchAndEmit
      type: ActionTypes.STOP_CLOCK
      gameId: @props.gameStateId
  startJam: () ->
    AppDispatcher.dispatchAndEmit
      type: ActionTypes.START_JAM
      gameId: @props.gameStateId
  stopJam: () ->
    AppDispatcher.dispatchAndEmit
      type: ActionTypes.STOP_JAM
      gameId: @props.gameStateId
  startLineup: () ->
    AppDispatcher.dispatchAndEmit
      type: ActionTypes.START_LINEUP
      gameId: @props.gameStateId
  startPregame: () ->
    AppDispatcher.dispatchAndEmit
      type: ActionTypes.START_PREGAME
      gameId: @props.gameStateId
  startHalftime: () ->
    AppDispatcher.dispatchAndEmit
      type: ActionTypes.START_HALFTIME
      gameId: @props.gameStateId
  startUnofficialFinal: () ->
    AppDispatcher.dispatchAndEmit
      type: ActionTypes.START_UNOFFICIAL_FINAL
      gameId: @props.gameStateId
  startOfficialFinal: () ->
    AppDispatcher.dispatchAndEmit
      type: ActionTypes.START_OFFICIAL_FINAL
      gameId: @props.gameStateId
  startTimeout: () ->
    AppDispatcher.dispatchAndEmit
      type: ActionTypes.START_TIMEOUT
      gameId: @props.gameStateId
  setTimeoutAsOfficialTimeout: () ->
    AppDispatcher.dispatchAndEmit
      type: ActionTypes.SET_TIMEOUT_AS_OFFICIAL_TIMEOUT
      gameId: @props.gameStateId
  setTimeoutAsHomeTeamTimeout: () ->
    AppDispatcher.dispatchAndEmit
      type: ActionTypes.SET_TIMEOUT_AS_HOME_TEAM_TIMEOUT
      gameId: @props.gameStateId
  setTimeoutAsHomeTeamOfficialReview: () ->
    AppDispatcher.dispatchAndEmit
      type: ActionTypes.SET_TIMEOUT_AS_HOME_TEAM_OFFICIAL_REVIEW
      gameId: @props.gameStateId
  setTimeoutAsAwayTeamTimeout: () ->
    AppDispatcher.dispatchAndEmit
      type: ActionTypes.SET_TIMEOUT_AS_AWAY_TEAM_TIMEOUT
      gameId: @props.gameStateId
  setTimeoutAsAwayTeamOfficialReview: () ->
    AppDispatcher.dispatchAndEmit
      type: ActionTypes.SET_TIMEOUT_AS_AWAY_TEAM_OFFICIAL_REVIEW
      gameId: @props.gameStateId
  setJamEndedByTime: () ->
    AppDispatcher.dispatchAndEmit
      type: ActionTypes.SET_JAM_ENDED_BY_TIME
      gameId: @props.gameStateId
  setJamEndedByCalloff: () ->
    AppDispatcher.dispatchAndEmit
      type: ActionTypes.SET_JAM_ENDED_BY_CALLOFF
      gameId: @props.gameStateId
  setJamClock: (value) ->
    AppDispatcher.dispatchAndEmit
      type: ActionTypes.SET_JAM_CLOCK
      gameId: @props.gameStateId
      value: value
  setPeriodClock: (value) ->
    AppDispatcher.dispatchAndEmit
      type: ActionTypes.SET_PERIOD_CLOCK
      gameId: @props.gameStateId
      value: value
  setHomeTeamTimeouts: (value) ->
    AppDispatcher.dispatchAndEmit
      type: ActionTypes.SET_HOME_TEAM_TIMEOUTS
      gameId: @props.gameStateId
      value: value
  setAwayTeamTimeouts: (value) ->
    AppDispatcher.dispatchAndEmit
      type: ActionTypes.SET_AWAY_TEAM_TIMEOUTS
      gameId: @props.gameStateId
      value: value
  setPeriodNumber: (value) ->
    AppDispatcher.dispatchAndEmit
      type: ActionTypes.SET_PERIOD_NUMBER
      gameId: @props.gameStateId
      value: value
  setJamNumber: (value) ->
    AppDispatcher.dispatchAndEmit
      type: ActionTypes.SET_JAM_NUMBER
      gameId: @props.gameStateId
      value: value
  removeHomeTeamOfficialReview: () ->
    AppDispatcher.dispatchAndEmit
      type: ActionTypes.REMOVE_HOME_TEAM_OFFICIAL_REVIEW
      gameId: @props.gameStateId
  removeAwayTeamOfficialReview: () ->
    AppDispatcher.dispatchAndEmit
      type: ActionTypes.REMOVE_AWAY_TEAM_OFFICIAL_REVIEW
      gameId: @props.gameStateId
  restoreHomeTeamOfficialReview: () ->
    AppDispatcher.dispatchAndEmit
      type: ActionTypes.RESTORE_HOME_TEAM_OFFICIAL_REVIEW
      gameId: @props.gameStateId
  restoreAwayTeamOfficialReview: () ->
    AppDispatcher.dispatchAndEmit
      type: ActionTypes.RESTORE_AWAY_TEAM_OFFICIAL_REVIEW
      gameId: @props.gameStateId
  render: () ->
    #CS = Class Set
    timeoutSectionCS =
      if ["jam", "lineup", "timeout", "unofficial_final"].indexOf(@props.state) != -1
        <div className="timeout-section row margin-xs">
          <div className="col-xs-12">
            <button className="bt-btn" onClick={@startTimeout}>TIMEOUT</button>
          </div>
        </div>
    timeoutExplanationSectionCS =
      if @props.state =="timeout"
        <div className="timeout-explanation-section row margin-xs">
          <div className="col-xs-4">
            <div className="home">
              <div className="row">
                <div className="col-md-12 col-xs-12">
                  <button className="bt-btn" onClick={@setTimeoutAsHomeTeamTimeout}>TIMEOUT</button>
                </div>
              </div>
              <div className="row margin-xs">
                <div className="col-md-12 col-xs-12">
                  <button className="bt-btn" onClick={@setTimeoutAsHomeTeamOfficialReview}>
                    <span className="hidden-xs">OFFICIAL REVIEW</span>
                    <span className="visible-xs-inline">REVIEW</span>
                  </button>
                </div>
              </div>
            </div>
          </div>
          <div className="col-md-4 col-xs-4">
            <button className="bt-btn" onClick={@setTimeoutAsOfficialTimeout}>
              <div>OFFICIAL</div>
              <div>TIMEOUT</div>
            </button>
          </div>
          <div className="col-md-4 col-xs-4 timeouts">
            <div className="away">
              <div className="row">
                <div className="col-md-12 col-xs-12">
                  <button className="bt-btn" onClick={@setTimeoutAsAwayTeamTimeout}>TIMEOUT</button>
                </div>
              </div>
              <div className="row margin-xs">
                <div className="col-md-12 col-xs-12">
                  <button className="bt-btn" onClick={@setTimeoutAsAwayTeamOfficialReview}>
                    <span className="hidden-xs">OFFICIAL REVIEW</span>
                    <span className="visible-xs-inline">REVIEW</span>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

    startClockSectionCS =
     if ["pregame", "halftime", "final"].indexOf(@props.state) != -1
      <div className='start-clock-section row margin-xs'>
        <div className="col-xs-12">
          <button className="bt-btn" onClick={@startClock}>START CLOCK</button>
        </div>
      </div>
    stopClockSectionCS =
      if ["pregame", "halftime", "final"].indexOf(@props.state) != -1
        <div className='stop-clock-section row margin-xs'>
          <div className="col-xs-12">
            <button className="bt-btn" onClick={@stopClock}>STOP CLOCK</button>
          </div>
        </div>
    startJamSectionCS =
      if ["pregame", "halftime", "lineup"].indexOf(@props.state) != -1
        <div className='start-jam-section row margin-xs'>
          <div className="col-xs-12">
            <button className="bt-btn" onClick={@startJam}>START JAM</button>
          </div>
        </div>
    stopJamSectionCS =
      if ["jam"].indexOf(@props.state) != -1
        <div className='stop-jam-section row margin-xs'>
          <div className="col-xs-12">
            <button className="bt-btn" onClick={@stopJam}>STOP JAM</button>
          </div>
        </div>
    startLineupSectionCS =
      if ["pregame", "halftime",  "timeout", "unofficial_final", "final"].indexOf(@props.state) != -1
          <div className='start-lineup-section row margin-xs'>
            <div className="col-xs-12 start-lineup-section">
              <button className="bt-btn" onClick={@startLineup}>START LINEUP</button>
            </div>
          </div>
    homeTeamOfficialReviewCS =
    homeTeamTimeoutClasses = [
      cx
        'official-review': true
        'bar': true
        'active': @props.home.isTakingOfficialReview
        'inactive': @props.home.hasOfficialReview == false
      cx
        'bar': true
        'active': @props.home.isTakingTimeout && @props.home.timeouts == 2
        'inactive': @props.home.timeouts < 3
      cx
        'bar': true
        'active': @props.home.isTakingTimeout && @props.home.timeouts == 1
        'inactive': @props.home.timeouts < 2
      cx
        'bar': true
        'active': @props.home.isTakingTimeout && @props.home.timeouts == 0
        'inactive': @props.home.timeouts < 1
    ]
    awayTeamTimeoutClasses = [
      cx
        'official-review': true
        'bar': true
        'active': @props.away.isTakingOfficialReview
        'inactive': @props.away.hasOfficialReview == false
      cx
        'bar': true
        'active': @props.away.isTakingTimeout && @props.away.timeouts == 2
        'inactive': @props.away.timeouts < 3
      cx
        'bar': true
        'active': @props.away.isTakingTimeout && @props.away.timeouts == 1
        'inactive': @props.away.timeouts < 2
      cx
        'bar': true
        'active': @props.away.isTakingTimeout && @props.away.timeouts == 0
        'inactive': @props.away.timeouts < 1
    ]
    <div className="jam-timer">
      <div className="row text-center">
        <div className="col-md-2 col-xs-2">
          <TimeoutBars
            homeOrAway="home"
            initials={@props.home.initials}
            classSets={homeTeamTimeoutClasses}
            reviewsRetained={@props.home.officialReviewsRetained}
            handleToggleTimeoutBar={@handleToggleTimeoutBar}
          />
        </div>
        <div className="col-md-8 col-xs-8">
          <JamAndPeriodNumbers
            periodNumber={@props.periodNumber}
            jamNumber={@props.jamNumber}
            clickJamEdit={@clickJamEdit}
            clickPeriodEdit={@clickPeriodEdit}/>
          <JTClocks
            jamLabel={@props.state.replace(/_/g, ' ')}
            jamClock={@props.jamClock.display()}
            periodClock={@props.periodClock.display()}
            jamClockClickHandler={@clickJamClockEdit}
            periodClockClickHandler={@clickPeriodClockEdit}
            ref="clocks"/>
        </div>
        <div className="col-md-2 col-xs-2">
          <TimeoutBars
            homeOrAway="away"
            initials={@props.away.initials}
            classSets=awayTeamTimeoutClasses
            reviewsRetained={@props.away.officialReviewsRetained}
            handleToggleTimeoutBar={@handleToggleTimeoutBar}
          />
        </div>
      </div>
      {timeoutSectionCS}
      {timeoutExplanationSectionCS}
      {startClockSectionCS}
      {stopClockSectionCS}
      {startJamSectionCS}
      {stopJamSectionCS}
      {startLineupSectionCS}
      <div className="modal" ref="modal">
        <div className="modal-dialog">
          <div className="modal-content">
            <div className="modal-header">
              <button type="button" className="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
              <h4 className="modal-title">Edit</h4>
            </div>
            <div className="modal-body">
              <input type="number" className="form-control" ref="modalInput"/>
            </div>
            <div className="modal-footer">
              <button type="button" className="btn btn-primary" onClick={@handleModal}>Save changes</button>
            </div>
          </div>
        </div>
      </div>
    </div>