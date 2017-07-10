%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. 七月 2017 11:32
%%%-------------------------------------------------------------------
-module(redis_event).
-author("cwt").

%% API
-export([start_link/0]).

-compile(export_all).

-define(SERVER,?MODULE).

start_link() ->
  gen_event:start_link({local,?MODULE}).

add_handle(Handle,Args) ->
  gen_event:add_handler(?MODULE,Handle,Args).

delete_handler(Handler, Args) ->
  gen_event:delete_handler(?SERVER, Handler, Args).

lookup(Key) ->
  gen_event:notify(?SERVER, {lookup, Key}).

add(Key, Value) ->
  gen_event:notify(?SERVER, {add, {Key, Value}}).

replace(Key, Value) ->
  gen_event:notify(?SERVER, {replace, {Key, Value}}).

delete(Key) ->
  gen_event:notify(?SERVER, {delete, Key}).






