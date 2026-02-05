extends FiniteStateMachine
class_name CotorraStates

var STATE_IDLE : StateCotorraIdle = StateCotorraIdle.new(self)
var STATE_DUCK : StateCotorraDuck = StateCotorraDuck.new(self)
var STATE_WALK : StateCotorraWalk = StateCotorraWalk.new(self)
