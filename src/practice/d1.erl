%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. 七月 2017 16:30
%%%-------------------------------------------------------------------
-module(d1).
-author("cwt").

%% API
-compile(export_all).

%%  讲一个元素复制n次，返回一个列表
%%  普通递归
du1(0, _) ->
  [];
du1(N, Value) ->
  [Value | du1(N - 1, Value)].

%%  使用尾递归实现(省空间)

du2(N, Value) ->
  du2(N, Value, []).
du2(0, _, List) ->
  List;
du2(N, Value, List) ->
  du2(N - 1, Value, [Value | List]).

start() ->
  du2(10, value).

%%  reverse 反转一个列表
reverse1([]) -> [];
reverse1([Top | Last]) ->
  [reverse1(Last) | Top].

%%  尾递归实现
reverse2(List) -> reverse2(List, []).
reverse2([], List) -> List;
reverse2([Top | Last], List) ->
  reverse2(Last, [List | Top]).

%%  接收一个list和N，返回列表前n个元素
sublist(List, N) -> sublist(List, N, []).

sublist(_, 0, NewList) -> NewList;
sublist([Top, Last], N, NewList) when N > 0 -> sublist(Last, N - 1, [Top | NewList]).

