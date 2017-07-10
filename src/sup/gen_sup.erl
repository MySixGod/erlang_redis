%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%   项目的根监督者
%%% @end
%%% Created : 10. 七月 2017 14:44
%%%-------------------------------------------------------------------
-module(gen_sup).
-author("cwt").

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).


start_link() ->
  supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->

  Redis = {redis_sup, {redis_sup, start_link, []},
    permanent, 2000, supervisor, [redis_sup]},

  EventManager = {redis_event, {redis_event, start_link, []},
    permanent, 2000, worker, [redis_event]},

  Children = [Redis, EventManager],
    RestartStrategy = {one_for_one, 4, 3600},
  {ok, {RestartStrategy,Children}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
