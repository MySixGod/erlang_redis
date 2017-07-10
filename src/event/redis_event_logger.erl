%%%-------------------------------------------------------------------
%%% @author cwt
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. 七月 2017 11:32
%%%-------------------------------------------------------------------
-module(redis_event_logger).
-author("cwt").

-behaviour(gen_event).

%% API
-export([add_handler/0]).

%% gen_event callbacks
-export([init/1,
  handle_event/2,
  handle_call/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {}).

add_handler() ->
  redis_event:add_handle(?SERVER,[]).

init([]) ->
  {ok, #state{}}.

handle_event({lookup, Key}, State) ->
  io:format("log:lookup ~p~n",[Key]),
  {ok, State};
handle_event({add, Key, Value}, State) ->
  io:format("log:add ~p,~p ~n",[Key,Value]),
  {ok, State};
handle_event({replace, Key, Value}, State) ->
  io:format("log:repalce ~p , ~p ~n",[Key,Value]),
  {ok, State};
handle_event({delete, Key}, State) ->
  io:format("log:delete ~p~n",[Key]),
  {ok, State}.

handle_call(_Request, State) ->
  Reply = ok,
  {ok, Reply, State}.

handle_info(_Info, State) ->
  {ok, State}.

terminate(_Arg, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
