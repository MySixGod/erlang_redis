%%%-------------------------------------------------------------------
%%% @author cwt
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 七月 2017 19:26
%%%-------------------------------------------------------------------
-module(example_worker).
-behaviour(gen_server).
-behaviour(poolboy_worker).

-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
    code_change/3]).

-record(state, {conn}).

start_link(Args) ->
    gen_server:start_link(?MODULE, Args, []).

init(Args) ->
    process_flag(trap_exit, true),
    Hostname = proplists:get_value(hostname, Args),
    Database = proplists:get_value(database, Args),
    Username = proplists:get_value(username, Args),
    Password = proplists:get_value(password, Args),
%%    {ok, Conn} = mysql:connect(Hostname, Username, Password, [
%%        {database, Database}
%%    ]),
    {ok, Conn} = mysql:start_link([{host, Hostname}, {port, 3306}, {user, Username},
     {password, Password}, {database, Database}]),
    {ok, #state{conn = Conn}}.

handle_call({query, Sql}, _From, #state{conn = Conn} = State) ->
    {reply, mysql:query(Conn, Sql), State};
handle_call({query, Stmt, Params}, _From, #state{conn = Conn} = State) ->
    {reply, mysql:query(Conn, Stmt, Params), State};
handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, #state{conn = Conn}) ->
%%    ok = mysql:close(Conn),
    {ok,Conn}.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
