%%%-------------------------------------------------------------------
%%% @author cwt
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. 七月 2017 15:27
%%%-------------------------------------------------------------------
-module(progress_pool).
-author("cwt").

-behaviour(gen_server).

%% API
-export([start_link/2]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).
-define(DEFAULT_SIZE, 20).

-record(state, {workerQueue, size, name}).

-compile(export_all).

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link(PoolArgs::list(), WorkerArgs::list()) ->
  {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link(PoolArgs, WorkerArgs) ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [PoolArgs, WorkerArgs], []).

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
init([PoolArgs, WorkerArgs]) ->
%%  默认的进程池大小
  Size = proplists:get_value(size, PoolArgs, ?DEFAULT_SIZE),
  io:format("pool size:~p~n", [Size]),
  WorkerQueue = append_child(Size, WorkerArgs),
  {ok, #state{workerQueue = WorkerQueue, size = Size, name = ?SERVER}}.


-spec append_child(Size :: integer(), WorkerArgs :: list()) ->
  WorkerQueue :: term().
append_child(Size, WorkerArgs) ->
  PidNameList = lists:foldl(
    fun(WorkerId, List) ->
      PidName = list_to_atom(lists:concat([pool_worker_, WorkerId])),
      {ok, _Pid} = pool_worker:start_link(PidName, WorkerArgs),
      [PidName | List]
    end, [], lists:seq(1,Size)),
  WorkerQueue = queue:from_list(PidNameList),
  io:format("WorkerQueue len:~p~n",[queue:len(WorkerQueue)]),
  WorkerQueue.

%%  同步执行同节点函数
execute(Module, F, Args) ->
  gen_server:call(?SERVER, {execute, Module, F, Args}).

execute_1(Module, F, Args) ->
  gen_server:cast(?SERVER, {execute, Module, F, Args}).

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%  同步调用
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
handle_call({execute, Module, F, Args}, _From, State) ->
  WorkerQueue = State#state.workerQueue,
  case queue:out(WorkerQueue) of
    {{value, PidName}, Q2}  ->
      Reply = gen_server:call(PidName, {execute, {Module, F, Args}, {_From,State#state.name}} ),
      {reply, Reply, #state{workerQueue = Q2, size = State#state.size - 1}};
%%    假如拿不到进程
    {empty, _}  ->
      io:format(" can't  get  progress ~n"),
      {noreply, State}
  end.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_cast(Request :: term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_cast({recycle, PidName}, State) ->
  io:format("-------PidName: ~p~n-----------", [PidName]),
  {noreply, #state{workerQueue = queue:in(PidName, State#state.workerQueue), size = State#state.size + 1,name = ?SERVER}};

handle_cast({execute, Module, F, Args}, State) ->
  WorkerQueue = State#state.workerQueue,
  Pid =self(),
  case queue:out(WorkerQueue) of
    {{value, PidName}, Q2}  ->
%%      如果运行失败记录到事件处理器
      {ok, _} = gen_server:call(PidName, {execute, {Module, F, Args}, {Pid, State#state.name}} ),
      {noreply, #state{workerQueue = Q2, size = State#state.size - 1}};
%%    假如拿不到进程
    {empty, _}  ->
      io:format(" can't  get  progress ~n"),
      {noreply, State}
  end.


%%  {noreply, #state{workerQueue = queue:in(PidName, State#state.workerQueue), size = State#state.size + 1,name = ?SERVER}}.

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
handle_info(_Info, State) ->
  {noreply, State}.

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
