%%%-------------------------------------------------------------------
%%% @author wt
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. 六月 2017 21:10
%%%-------------------------------------------------------------------
-module(redis_store).
-author("wt").

-define(TABLE_ID,?MODULE).
%% API
-compile(export_all).

init() ->
  ets:new(?TABLE_ID, [public,named_table]),
  ok.

insert(Key,Pid) ->
  ets:insert(?TABLE_ID,{Key,Pid}).

lookup(Key) ->
  case ets:lookup(?TABLE_ID,{Key,'_'}) of
    [{Key,Pid}] -> {ok,Pid};
    _ -> {error,not_found}
  end.

%%  通过进程删除key
delete(Pid) ->
  ets:delete(?TABLE_ID,{'_',Pid}).


