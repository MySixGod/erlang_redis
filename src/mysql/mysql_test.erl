%%%-------------------------------------------------------------------
%%% @author cwt
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 七月 2017 16:41
%%%-------------------------------------------------------------------
-module(mysql_test).
-author("cwt").

%% API
-compile(export_all).

get_connect() ->
  {ok, Pid} = mysql:start_link([{host, "localhost"}, {port, 3306}, {user, "root"},
    {password, "cwtborn123"}, {database, "hello"}]),
  Pid.

test() ->
  mysql:query(get_connect(), "INSERT INTO hello_table (hello_text) VALUES (?)", [1]).


test2() ->
%%  handle_call({query, Sql}, _From, #state{conn = Conn} = State) ->
%%  {reply, mysql:query(Conn, Sql), State};
  example:query(pool1,<<"SELECT * FROM hello_table">>).

look() ->
  {ok, ColumnNames, Rows} =
    mysql:query(get_connect(), <<"SELECT * FROM hello_table">>),
  io:format("ColumnName:~p~n Rows:~p~n", [ColumnNames, Rows]),
  [Top|_] = Rows,
  [Value|_] =  Top,
  binary_to_list(Value).



%%query() ->
%%  Pid = get_connect(),
%%  Result = mysql:transaction(Pid, fun() ->
%%    ok = mysql:query(Pid, "INSERT INTO hello_table (hello_text) VALUES (ok)"),
%%    throw(foo),
%%    ok = mysql:query(Pid, "INSERT INTO hello_table (hello_text) VALUES (ok)")
%%                                  end),
%%  case Result of
%%    {atomic, ResultOfFun} ->
%%      io:format("Inserted 2 rows,result: ~p ~n",[ResultOfFun]);
%%    {aborted, Reason} ->
%%      io:format("Inserted 0 rows,reson: ~p ~n",[Reason])
%%  end.





















