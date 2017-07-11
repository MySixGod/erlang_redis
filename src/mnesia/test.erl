%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. 七月 2017 15:44
%%%-------------------------------------------------------------------
-module(test).
-author("cwt").

-record(key_to_pid, {key, pid}).

%% API
-compile(export_all).

start() ->
  mnesia:stop(),
  mnesia:create_table(key_to_pid,
    [{index, [pid]},
      {attributes, record_info(fields, key_to_pid)}
    ]),
  mnesia:start().


