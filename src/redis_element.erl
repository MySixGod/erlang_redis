%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. 六月 2017 11:51
%%%-------------------------------------------------------------------
-module(redis_element).
-author("cwt").

-behaviour(gen_server).

%% API
-export([start_link/2,create/2,create/1,fetch/1,replace/2,delete/1]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).
%%  一天的总秒数
-define(DEFAULT_CACHE_TIME,24*60*60).

%%  状态记录
-record(state, {value,lease_time,start_time}).


start_link(Value,LeaseTime) ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [Value,LeaseTime], []).

create(Value,LeaseTime) ->
  redis_sup:start_child(Value,LeaseTime).

create(Value) ->
  redis_sup:start_child(Value,?DEFAULT_CACHE_TIME).

fetch(Pid) ->
  gen_server:call(Pid,fetch).

replace(Pid,Value) ->
  gen_server:cast(Pid,{replace,Value}).

delete(Pid) ->
  gen_server:cast(Pid,delete).


%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([Value,LeaseTime]) ->
  Now=calendar:local_time(),
  StartTime=calendar:datetime_to_gregorian_seconds(Now),
  {ok, #state{value = Value,lease_time = LeaseTime,start_time = StartTime},time_left(StartTime,LeaseTime)}.

time_left(_,infinity) ->
  infinty;
time_left(StartTime,LeaseTime) ->
  Now=calendar:local_time(),
  CurrentTiem=calendar:datetime_to_gregorian_seconds(Now),
  TimeElapased=CurrentTiem-StartTime,
  case LeaseTime-TimeElapased of
    Time when Time<0 -> 0;
    Time -> Time*1000
  end.


handle_call(fetch, _From, State) ->
  #state{value = Value,lease_time = LeaseTime,start_time = StartTime}=State,
  TimeLeft=time_left(StartTime,LeaseTime),
  {reply, {ok,Value}, State,TimeLeft}.


handle_cast({replace,Value}, State) ->
  #state{lease_time = LeaseTime, start_time = StartTime}=State,
  TimeLeft=time_left(StartTime,LeaseTime),
  {noreply, State#state{value=Value},TimeLeft};
handle_cast(delete,State) ->
  {stop,normal,State}.


handle_info(timeout, State) ->
  {stop, normal,State}.


terminate(_Reason, _State) ->
  ok.


code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
