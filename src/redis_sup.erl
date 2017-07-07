%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. 六月 2017 11:38
%%%-------------------------------------------------------------------
-module(redis_sup).
-author("cwt").

-behaviour(supervisor).

%% API
-export([start_link/0,start_child/2]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
  supervisor:start_link({local, ?SERVER}, ?MODULE, []).

start_child(Value,LeaseTime) ->
  supervisor:start_child(?SERVER,[Value,LeaseTime]).

init([]) ->
  RestartStrategy = simple_one_for_one,
%%  一段时间内最大重启次数
  MaxRestarts = 0,
%%  时间间隔
  MaxSecondsBetweenRestarts = 1,

  SupFlags = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},
%%  restart() = permanent | transient | temporary
  Restart = transient,
%%  进程出了问题给它时间进行自我结束，如果不能自己结束，超过设置的时间强行结束
%%   brutal_kill | timeout()
  Shutdown = brutal_kill,

  Type = worker,

  AChild = {redis_element, {redis_element, start_link, []},
    Restart, Shutdown, Type, [redis_element]},

  {ok, {SupFlags, [AChild]}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
