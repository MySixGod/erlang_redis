%%%-------------------------------------------------------------------
%%% @author cwt
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. 七月 2017 16:17
%%%-------------------------------------------------------------------
-module(fsm).
-behaviour(gen_fsm).

-export([start_link/1]).
-export([button/1]).

-export([init/1, locked/2, open/2]).
-export([code_change/4, handle_event/3, handle_info/3, handle_sync_event/4, terminate/3]).

-define(SERVER,?MODULE).

start_link(Code) ->
  gen_fsm:start_link({local, ?SERVER}, ?SERVER, Code, []).

button(Digit) ->
  gen_fsm:send_event(?SERVER, {button, Digit}).

init(LockCode) ->
  io:format("init: ~p~n", [LockCode]),
%%  {ok,StateName,{}}
  {ok, locked, {[], LockCode}}.

locked({button, Digit}, {SoFar, Code}) ->
  io:format("buttion: ~p, So far: ~p, Code: ~p~n", [Digit, SoFar, Code]),
  InputDigits = lists:append(SoFar, Digit),
  case InputDigits of
    Code ->
      do_unlock(),
      {next_state, open, {[], Code}, 10000};
    Incomplete when length(Incomplete)<length(Code) ->
      {next_state, locked, {Incomplete, Code}, 5000};
    Wrong ->
      io:format("wrong passwd: ~p~n", [Wrong]),
      {next_state, locked, {[], Code}}
  end;
locked(timeout, {_SoFar, Code}) ->
  io:format("timout when waiting button inputting, clean the input, button again plz~n"),
  {next_state, locked, {[], Code}}.

open(timeout, State) ->
  do_lock(),
  {next_state, locked, State}.

code_change(_OldVsn, StateName, Data, _Extra) ->
  {ok, StateName, Data}.

terminate(normal, _StateName, _Data) ->
  ok.

handle_event(Event, StateName, Data) ->
  io:format("handle_event... ~n"),
  unexpected(Event, StateName),
  {next_state, StateName, Data}.

handle_sync_event(Event, From, StateName, Data) ->
  io:format("handle_sync_event, for process: ~p... ~n", [From]),
  unexpected(Event, StateName),
  {next_state, StateName, Data}.

handle_info(Info, StateName, Data) ->
  io:format("handle_info...~n"),
  unexpected(Info, StateName),
  {next_state, StateName, Data}.


%% Unexpected allows to log unexpected messages
unexpected(Msg, State) ->
  io:format("~p RECEIVED UNKNOWN EVENT: ~p, while FSM process in state: ~p~n",
    [self(), Msg, State]).
%%
%% actions
do_unlock() ->
  io:format("passwd is right, open the DOOR.~n").

do_lock() ->
  io:format("over, close the DOOR.~n").