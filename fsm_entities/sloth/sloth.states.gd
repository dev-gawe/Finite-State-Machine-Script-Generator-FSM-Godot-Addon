extends FiniteStateMachine
class_name SlothStates

var STATE_IDLE : StateSlothIdle = StateSlothIdle.new(self)
var STATE_REST : StateSlothRest = StateSlothRest.new(self)

var STATE_RUN : StateSlothRun = StateSlothRun.new(self)
