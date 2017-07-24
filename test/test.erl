%%%-------------------------------------------------------------------
%%% @author cwt
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. 七月 2017 14:53
%%%-------------------------------------------------------------------
-module(test).
-author("cwt").

-include_lib("eunit/include/eunit.hrl").

-compile(export_all).

-define(STATE,#{a => b, b => c}).

simple_test() ->
  C = ?STATE#{a => b},
  maps:find(b, C).

say() ->
  code:get_object_code(test).

process_infos() ->
  filelib:ensure_dir("./log/"),
  File = "./log/processes_infos.log",
  {ok, Fd} = file:open(File, [write, raw, binary, append]),
  Fun = fun(Pi) ->
    Info = io_lib:format("=>~p \n\n", [Pi]),
    case filelib:is_file(File) of
      true -> file:write(Fd, Info);
      false ->
        file:close(Fd),
        {ok, NewFd} = file:open(File, [write, raw, binary, append]),
        file:write(NewFd, Info)
    end,
    timer:sleep(20)
        end,
  [Fun(erlang:process_info(P)) || P <- erlang:processes()].


list() ->
  L=[229,136,157,231,186,167],
  io:format("~ts", [list_to_binary(L)]).

%%  输出三角形
san() ->
  [begin List = lists:duplicate(X, "*"),io:format("~s~n",[lists:duplicate((20-X) div 2, " ") ++ List]) end || X <- lists:seq(1,20,2)].

%%  输出9*9

jiu() ->
  [begin List = lists:seq(1,9),lists:foreach(fun(Y) -> io:format("~p * ~p = ~p;  ",[X, Y, X*Y])  end,List),io:format("~n") end || X <- lists:seq(1,9)].


tt()  ->
  Tree1 = gb_trees:insert(2,2,gb_trees:empty()),
  Tree2 = gb_trees:insert(3,1,Tree1),
  Tree3 = gb_trees:insert(1,3,Tree2),
%%  next(Iter1) -> none | {Key, Value, Iter2}
  Iter1 = gb_trees:iterator(Tree3),
  li(Iter1).


li(Iter1) ->
  case gb_trees:next(Iter1)  of
    none -> nil;
    {Key, Value, Iter2} -> io:format("key:~p value: ~p ~n",[Key,Value]),li(Iter2)
  end.

