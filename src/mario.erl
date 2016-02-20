-module(mario).
-behaviour(gen_server).
-behaviour(poolboy_worker).

-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
  code_change/3]).

-record(state, {}).

start_link(Args) ->
  gen_server:start_link(?MODULE, Args, []).

init(_Args) ->
  {ok, #state{}}.

handle_call(_Request, _From, State) ->
  {reply, ok, State}.

handle_cast({account, Acc}, State) ->
  {noreply, State}.

handle_cast(_Msg, State) ->
  {noreply, State}.

handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, #state{conn=Conn}) ->
  ok = epgsql:close(Conn),
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.



%%%===================================================================
%%% Internal functions
%%%===================================================================
pipe_spec(Email)->
  {Email, {in_pipe, start_link, [Email]}, permanent, 2000, worker, [in_pipe]}.

start_pipe(Email)->
  ChildSpec = pipe_spec(Email),
  supervisor:start_child(?SERVER, ChildSpec).