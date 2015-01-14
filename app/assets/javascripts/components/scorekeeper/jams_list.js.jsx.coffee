exports = exports ? this
exports.JamsList = React.createClass
  handleJamSelection: (jamNumber) ->
    console.log "handleJamSelection"
    console.log jamNumber
    console.log this.props

  getInitialState: () ->
    this.state = this.props

  render: () ->
    JamItemFactory = React.createFactory(JamItem)
    # jam's schema is same as jam_state table
    jamComponents = this.props.jams.map (jam) =>
      JamItemFactory({key: jam.jamNumber, jam: jam, teamType: this.props.teamType, selectionHandler: this.handleJamSelection.bind(this, jam.jamNumber)})
    jamComponents.push(JamItemFactory({key: "0", jam: {skaterNumber: "Skater", jamNumber: this.props.jams.length+1}, teamType: this.props.teamType, selectionHandler: this.handleJamSelection.bind(this, this.props.jams.length+1)}))
    return(
      `<div className="jams">
        <div className="headers">
          <div className="row gutters-xs">
            <div className="col-sm-2 col-xs-2">
              <strong>Jam</strong>
            </div>
            <div className="col-sm-2 col-xs-2">
              <strong>Skater</strong>
            </div>
            <div className="col-sm-2 col-xs-2 col-sm-offset-2 col-xs-offset-2 text-center">
              <strong>Notes</strong>
            </div>
            <div className="col-sm-2 col-xs-2 col-sm-offset-2 col-xs-offset-2 text-center">
              <strong>Points</strong>
            </div>
          </div>
        </div>
        <div className="columns">
          {jamComponents}
        </div>
      </div>
      `
    )
