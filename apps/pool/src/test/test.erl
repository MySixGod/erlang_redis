%%%-------------------------------------------------------------------
%%% @author cwt  <woshi6ye@gmail.com>
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. 七月 2017 9:41
%%%-------------------------------------------------------------------
-module(test).
-author("cwt").

%% API
-export([]).

-compile(export_all).

test1() ->
  progress_pool:execute(test, say, []).

test2() ->
  progress_pool:execute_1(test, say, []).

t2() ->
  t:start_link(),
  gen_server:call(t,{}, 1000).


say() ->
  hello.


ex() ->
  case catch throw(error) of
    Message ->
      io:format("Message:~p~n",[Message])
  end.