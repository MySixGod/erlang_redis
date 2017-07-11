%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%   实现分布式资源的探测:每个节点单独启动，提供自己的资源，并能获取其他节点的资源(注意：所有不同资源的key必须保持不同，否则可能在
%%%   对资源进行合并的时候回丢失资源)
%%% TODO 周期性对节点的资源进行检测,清空失效的资源
%%% @end
%%% Created : 10. 七月 2017 19:08
%%%-------------------------------------------------------------------
-module(resource_discovery).
-author("cwt").

-behaviour(gen_server).

%% API
-compile(export_all).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).

-define(NODES,[]).

-record(state, {local_resource,target_resource,found_resource}).

%%  @param 本地资源，目标资源，节点列表
start_link([LocalResource,TargetResource]) ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [list_to_dict(LocalResource),TargetResource], []),
  erlang:send_after(1000,self(),resource_init).

%%  初始化
init([LocalResourceDict,TargetResource]) ->
  {ok, #state{local_resource = LocalResourceDict,target_resource = TargetResource,found_resource = dict:new()}}.

%%  将列表转化为字典存储
list_to_dict(List) ->
  list_to_dict(List,dict:new()).

list_to_dict([{Key,Value}|Last],Dict) ->
  list_to_dict(Last,dict_add(Dict,{Key,Value}));
list_to_dict([],Dict) ->
  Dict.

dict_add(Dict,{Key,Value}) ->
  dict:store(Key,Value,Dict).

%%  添加本地资源方法
add_local_resource(Key,Value) ->
  gen_server:cast(?SERVER,{add_local_resource,{Key,Value}}).

%%  添加目标资源
add_target_resource(Key) ->
  gen_server:cast(?SERVER,{add_local_resource,Key}).


handle_call(_Request, _From, State) ->
  {reply, ok, State}.

%%  接受所需要的资源
handle_cast({reply_resource,NeedResourceList}, State) ->
%%  更新自己的found_resource
  NewFoundResource=dict:from_list(NeedResourceList ++ dict:to_list(State#state.found_resource)),
  {noreply, State#state{
    found_resource = NewFoundResource
  }};
%%  添加本地资源
handle_cast({add_local_resource,{Key,Value}}, State) ->
  OldLocalResource = State#state.local_resource,
  NewLocalResource = OldLocalResource ++ [{Key,Value}],
  erlang:send_after(1000,self(),{resource_init,?NODES}),
  {noreply,State#state{local_resource = NewLocalResource}};
%%  添加目标资源
handle_cast({add_target_resource,Key}, State) ->
  {noreply,State#state{target_resource = State#state.target_resource++Key}}.


%%  向其他的节点发送信息，提供自己的资源
handle_info(resource_init, State) ->
  lists:foreach(fun(Node) ->
%%    将自己拥有的资源发送到其他节点,和自己需要的资源列表
    {?SERVER,Node} ! {my_resource,self(),State#state.local_resource,State#state.target_resource} end,?NODES),
  {noreply, State};

handle_info({my_resource,Pid,Dict,TargetResource}, State) ->
%%  查看是否有自己需要的资源1.修复无法重复存储Value的问题
  TargetResourceList = lists:foldl(
    fun(Key,Acc) ->
      case dict:find(Key,Dict) of
        {ok,Value}->[{Key,Value}|Acc];
        error ->Acc
       end
    end,[],State#state.target_resource),
    NewFoundResource = dict:from_list(TargetResourceList ++ dict:to_list(State#state.found_resource)),

%%  查看是否持有发送者需要的资源
  NeedResourceList = lists:foldl(
    fun(Key,Acc) ->
      case dict:find(Key,State#state.local_resource) of
        {ok,Value}->[{Key,Value}|Acc];
        error ->Acc
      end
    end,[],TargetResource),
%%  将对方需要的资源返回
  gen_server:cast(Pid,{reply_resource,NeedResourceList}),
%%  更新线程状态
  {noreply,State#state{found_resource = NewFoundResource}}.




terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.


