-module(mario).
-behaviour(gen_server).
-behaviour(poolboy_worker).

-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
  code_change/3]).

-type state() :: {TaskType :: idle|account|in_pipe|email|badge, Task :: term()}.

-include("messages.hrl").

-import(transforms, []).
-import(store, []).
-import(gen_tcp, []).

start_link(Args) ->
  gen_server:start_link(?MODULE, Args, [self()]).

init(Sup) ->
  put(sup, Sup),
  {ok, {idle}}.

%%adding a single account, probably from the clientgate request
handle_call({account, Acc}, From, _State) ->
  case store:locate_pipe(Acc#account.email) of
    undefined ->
      #account{creds = Cred} = Acc,
      {ok, Socket} = in_pipe:start(Cred),
      gen_tcp:controlling_process(Socket, From),
      {reply, {ok, Cred, Socket}, {idle}};

    Pid ->
      Pid ! {add_device, Acc},
      {reply, ok, {idle}}
  end;

%%adding a batch of accounts, probably on app start
handle_call({in_pipe, Creds}, From, _State) ->
  Selected = lists:nth( -erlang:monotonic_time() rem length(Creds),  Creds),
  {ok, Socket} = in_pipe:start(Selected),
  ok = gen_tcp:controlling_process(Socket, From),
  {reply, {ok, Selected, Socket}, {idle}};

handle_call(_Request, _From, State) ->
  {reply, ok, State}.


handle_cast(_Msg, State) ->
  {noreply, State}.

handle_info(process, _State) ->
  {noreply, _State};


handle_info(_Info, State) ->
  {noreply, State}.


terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.


%%%===================================================================
%%% Accounts saving task
%%%===================================================================



