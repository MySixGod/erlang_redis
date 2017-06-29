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

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link(_,_) ->
  {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
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

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
  {ok, State :: #state{}} | {ok, State :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term()} | ignore).
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

%%--------------------------------------------------------------------
%% @doc
%% Handling call messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: #state{}) ->
  {reply, Reply :: term(), NewState :: #state{}} |
  {reply, Reply :: term(), NewState :: #state{}, timeout() | hibernate} |
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), Reply :: term(), NewState :: #state{}} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_call(fetch, _From, State) ->
  #state{value = Value,lease_time = LeaseTime,start_time = StartTime}=State,
  TimeLeft=time_left(StartTime,LeaseTime),
  {reply, {ok,Value}, State,TimeLeft}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%% @end
%%--------------------------------------------------------------------
-spec(handle_cast(Request :: term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_cast({replace,Value}, State) ->
  #state{lease_time = LeaseTime, start_time = StartTime}=State,
  TimeLeft=time_left(StartTime,LeaseTime),
  {noreply, State#state{value=Value},TimeLeft};
handle_cast(delete,State) ->
  {stop,normal,State}.


%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
-spec(handle_info(Info :: timeout() | term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_info(timeout, State) ->
  {stop, normal,State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
    State :: #state{}) -> term()).
terminate(_Reason, _State) ->
  ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #state{},
    Extra :: term()) ->
  {ok, NewState :: #state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
