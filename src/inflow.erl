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
-export([start_link/0, serve/2]).

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
  PoolName = marios,

  Marios = poolboy:child_spec(PoolName, [
    {name, {local, PoolName}},
    {worker_module, mario},
    {size, 5},
    {max_overflow, 10}
  ], [self()]),

  Services = [{dbserver, {legacydb, start_link, []}, transient, 2000, worker, [legacydb]}],

  {ok, {{one_for_one, 1000, 10}, Services ++ Marios}}.


serve (Type, Acc)->
  poolboy:transaction(marios, fun(Worker) ->
    gen_server:call(Worker, {Type, Acc})
  end).


%%%===================================================================
%%% Internal functions
%%%===================================================================


