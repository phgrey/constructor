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

start_link(Args) ->
  gen_server:start_link(?MODULE, Args, [self()]).

init(Sup) ->
  put(sup, Sup),
  {ok, {idle}}.

%%adding a single account, probably from the clientgate request
handle_call({account, Acc}, _From, {idle}) ->
  case store:locate_pipe(Acc#account.email) of
    undefined ->
      {ok, Pid} = start_pipe(Acc, get(sup));
    Pid ->
      {exists, Pid}
  end,
  {reply, ok, {account, Acc}};



handle_call(_Request, _From, State) ->
  {reply, ok, State}.


handle_cast(_Msg, State) ->
  {noreply, State}.

handle_info(process, {account, Acc}) ->

  {noreply, State}.


handle_info(_Info, State) ->
  {noreply, State}.


terminate(_Reason, State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.



%%%===================================================================
%%% Email registering task
%%%===================================================================
%%TODO: this is a robustivity test for erlang)))) single observer, tonns of global names - fixit!
get_pipe(Email)->
  whereis(Email).

set_pipe(Email, Pid)->
  register({local, Email}, Pid).


%%%===================================================================
%%% Accounts saving task
%%%===================================================================


start_pipe(Acc, Sup) ->
  ImapSpec = {Acc#account.email, {?MODULE, start_link, [Acc]}, permanent, 2000, worker},
  {ok, Child} = supervisor:start_child(Sup, ImapSpec), Child.



-import(eimap, []).
-include_lib("eimap/src/eimap.hrl").


start_link(Accounts) ->
  Acc = lists:nth( -erlang:monotonic_time() rem length(Accounts),  Accounts),
  imap_connect(Acc).

%%eimap - specific part
imap_connect(Acc) ->
  #account{creds={Server, Auth, Add}, token=Token} = Acc,
  Conf = #eimap_server_config{host = atom_to_list(Server#server.host), port = Server#server.port,
    tls=Server#server.crypt == ssl},
  {ok, Conn} = eimap:start_link(Conf),
  eimap:connect(Conn, self(), undefined),
%%  Caps = eimap:capabilities(Conn, self(), undefined),
  imap_login(Conn, Auth).


imap_login(Conn, {plain, Login, Pass})->
  eimap:login(Conn, self(), Login, Pass).
