extends FiniteStateMachine
class_name SlothStates

var STATE_IDLE : StateSlothIdle = StateSlothIdle.new(self)
var STATE_REST : StateSlothRest = StateSlothRest.new(self)
var STATE_WALK : StateSlothWalk = StateSlothWalk.new(self)
var STATE_CLIMB : StateSlothClimb = StateSlothClimb.new(self)
