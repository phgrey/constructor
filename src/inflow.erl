%%%-------------------------------------------------------------------
%%% @author phgrey
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. Feb 2016 8:21
%%%-------------------------------------------------------------------
-module(inflow).
-author("phgrey").

-behaviour(supervisor).

%% API
-export([start_link/0, start_pipe/1]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%-on_load(Name/0)

%%%===================================================================
%%% API functions
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the supervisor
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link() ->
  {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
  supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%%===================================================================
%%% Supervisor callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a supervisor is started using supervisor:start_link/[2,3],
%% this function is called by the new process to find out about
%% restart strategy, maximum restart frequency and child
%% specifications.
%%
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
  {ok, {SupFlags :: {RestartStrategy :: supervisor:strategy(),
    MaxR :: non_neg_integer(), MaxT :: non_neg_integer()},
    [ChildSpec :: supervisor:child_spec()]
  }} |
  ignore |
  {error, Reason :: term()}).
init([]) ->
  RestartStrategy = one_for_one,
  MaxRestarts = 1000,
  MaxSecondsBetweenRestarts = 3600,

  SupFlags = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},

  Restart = transient,
  Shutdown = 2000,
  Module = mario,

  Marios = [ {list_to_atom("worker" ++ integer_to_list(X)), {Module, start_link, []},
    Restart, Shutdown, worker, [Module]} || X <- lists:seq(0,9)],

  Services = [{dbserver, {database, start_link, []}, transient, 2000, worker, [database]}],

  {ok, {SupFlags, Services ++ Marios}}.

start_pipe(Email)->
  ChildSpec = pipe_spec(Email),
  supervisor:start_child(?SERVER, ChildSpec).

%%%===================================================================
%%% Internal functions
%%%===================================================================

pipe_spec(Email)->
  {Email, {in_pipe, start_link, [Email]}, permanent, 2000, worker, [in_pipe]}.

