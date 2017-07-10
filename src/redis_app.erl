%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. 六月 2017 11:36
%%%-------------------------------------------------------------------
-module(redis_app).
-author("cwt").

-behaviour(application).

%% Application callbacks
-export([start/0,start/2,
  stop/1]).

start(_,_) ->
  start().

%%  在这里启动根监督者
start() ->
  case gen_sup:start_link() of
    {ok, Pid} ->
      %%      初始化ets
      redis_store:init(),
      %%      添加处理者
      redis_event_logger:add_handler(),
      {ok, Pid};
    Error ->
      Error
  end.

stop(_State) ->
  ok.

%%%===================================================================
%%% Internal functions
%%%===================================================================
