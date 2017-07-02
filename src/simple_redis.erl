%%%-------------------------------------------------------------------
%%% @author wt
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. 六月 2017 22:14
%%%-------------------------------------------------------------------
-module(simple_redis).
-author("wt").

%% API
-compile(export_all).

add(Key,Value) ->
  case redis_store:lookup(Key) of
%%    更新进程存储的数据
    {ok,Pid} ->redis_element:replace(Pid,Value);
    {error,_} ->
%%      没有就先创建一个进程
      {ok,Pid}=redis_element:create(Value),
      redis_store:insert(Key,Pid)
  end.

delete_element(Key)->
  case redis_store:lookup(Key)  of
    {ok,Pid} ->
%%      也可以不结束进程，让它超时自动销毁
      gen_server:stop(Pid,normal,1000),
      redis_store:delete(Pid);
    {error,Message} ->
      io:format("~p~n",[Message])
  end.

lookup(Key) ->
    case redis_store:lookup(Key) of
      {ok,Pid} ->
        case redis_element:fetch(Pid) of
          {ok,Value} ->
            Value
        end;
      {error,Message} ->
        io:format("error ~p~n",[Message])
    end.