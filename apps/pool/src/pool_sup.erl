%%%-------------------------------------------------------------------
%%% @author cwt
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. 七月 2017 15:23
%%%-------------------------------------------------------------------
-module(pool_sup).
-author("cwt").

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%%===================================================================
%%% API functions
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the supervisor
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link() ->
  {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
  supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%%===================================================================
%%% Supervisor callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a supervisor is started using supervisor:start_link/[2,3],
%% this function is called by the new process to find out about
%% restart strategy, maximum restart frequency and child
%% specifications.
%%
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
  {ok, {SupFlags :: {RestartStrategy :: supervisor:strategy(),
    MaxR :: non_neg_integer(), MaxT :: non_neg_integer()},
    [ChildSpec :: supervisor:child_spec()]
  }} |
  ignore |
  {error, Reason :: term()}).
init([]) ->
  RestartStrategy = one_for_one,
  MaxRestarts = 10,
  MaxSecondsBetweenRestarts = 10,

  SupFlags = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},

  Restart = permanent,
  Shutdown = 2000,
  Type = worker,

  {ok, Pools} = application:get_env(pool, pools),
%%  {pool1, [{size, 10}, {max_overflow, 20}], []}
  PoolSpecs = lists:map(fun({Name, PoolArgs, WorkerArgs}) ->
                          child_spec(Name, PoolArgs, WorkerArgs, Restart, Shutdown, Type)
                        end, Pools),
  {ok, {SupFlags, [PoolSpecs]}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

%%  AChild = {'AName', {'AModule', start_link, []},
%%  Restart, Shutdown, Type, ['AModule']},
child_spec(PoolId, PoolArgs, WorkerArgs, Restart, Shutdown, Type) ->
  {PoolId, {progress_pool, start_link, [PoolArgs, WorkerArgs]},
    Restart, Shutdown, Type, [progress_pool]}.