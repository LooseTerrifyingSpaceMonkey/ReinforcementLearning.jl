export RockPaperScissorsEnv

"""
    RockPaperScissorsEnv()

[Rock Paper Scissors](https://en.wikipedia.org/wiki/Rock_paper_scissors) is a
simultaneous, zero sum game.
"""
Base.@kwdef mutable struct RockPaperScissorsEnv <: AbstractEnv
    reward::NamedTuple{(Symbol(1), Symbol(2)), Tuple{Int64, Int64}} = (; Symbol(1) => 0, Symbol(2) => 0)
    is_done::Bool = false
end

RLBase.players(::RockPaperScissorsEnv) = (Symbol(1), Symbol(2))

"""
Note that although this is a two player game. The current player is always a
dummy simultaneous player.
"""
RLBase.current_player(::RockPaperScissorsEnv) = SIMULTANEOUS_PLAYER

RLBase.action_space(::RockPaperScissorsEnv, ::Symbol) = ('💎', '📃', '✂')

RLBase.action_space(::RockPaperScissorsEnv, ::SimultaneousPlayer) =
    Tuple((i, j) for i in ('💎', '📃', '✂') for j in ('💎', '📃', '✂'))

RLBase.action_space(env::RockPaperScissorsEnv) = action_space(env, SIMULTANEOUS_PLAYER)

RLBase.legal_action_space(env::RockPaperScissorsEnv, p) =
    is_terminated(env) ? () : action_space(env, p)

"Since it's a one-shot game, the state space doesn't have much meaning."
RLBase.state_space(::RockPaperScissorsEnv, ::Observation, p) = Base.OneTo(1)

"""
For multi-agent environments, we usually implement the most detailed one.
"""
RLBase.state(::RockPaperScissorsEnv, ::Observation, p) = 1

RLBase.reward(env::RockPaperScissorsEnv) = env.is_done ? env.reward : (; Symbol(1) => 0, Symbol(2) => 0)
RLBase.reward(env::RockPaperScissorsEnv, p::Symbol) = reward(env)[p]

RLBase.is_terminated(env::RockPaperScissorsEnv) = env.is_done
RLBase.reset!(env::RockPaperScissorsEnv) = env.is_done = false

function (env::RockPaperScissorsEnv)((x, y))
    if x == y
        env.reward = (; Symbol(1) => 0, Symbol(2) => 0)
    elseif x == '💎' && y == '✂' || x == '✂' && y == '📃' || x == '📃' && y == '💎'
        env.reward = (; Symbol(1) => 1, Symbol(2) => -1)
    else
        env.reward = (; Symbol(1) => -1, Symbol(2) => 1)
    end
    env.is_done = true
end

RLBase.NumAgentStyle(::RockPaperScissorsEnv) = MultiAgent(2)
RLBase.DynamicStyle(::RockPaperScissorsEnv) = SIMULTANEOUS
RLBase.ActionStyle(::RockPaperScissorsEnv) = MINIMAL_ACTION_SET
RLBase.InformationStyle(::RockPaperScissorsEnv) = IMPERFECT_INFORMATION
RLBase.StateStyle(::RockPaperScissorsEnv) = Observation{Int}()
RLBase.RewardStyle(::RockPaperScissorsEnv) = TERMINAL_REWARD
RLBase.UtilityStyle(::RockPaperScissorsEnv) = ZERO_SUM
RLBase.ChanceStyle(::RockPaperScissorsEnv) = DETERMINISTIC
