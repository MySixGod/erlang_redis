%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. 六月 2017 11:28
%%%-------------------------------------------------------------------
-module(demo1).
-author("Administrator").

%% API
-compile(export_all).

-record(mail,{
  a=1,
  b=2
}).

say() ->
  {#mail.a,#mail.b}.



~~







