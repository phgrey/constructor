-module(castle).
-behaviour(gen_server).
-define(SERVER, ?MODULE).

-include("messages.hrl").
-import(store, []).

-type state() :: [{Email :: email(), Accounts :: [account()], UsedToken :: push_token(), Socket :: port()}].

%% ------------------------------------------------------------------
%% API Function Exports
%% ------------------------------------------------------------------

-export([start_link/1]).

%% ------------------------------------------------------------------
%% gen_server Function Exports
%% ------------------------------------------------------------------

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
  terminate/2, code_change/3]).

%% ------------------------------------------------------------------
%% API Function Definitions
%% ------------------------------------------------------------------

start_link(Emails) ->
%%  put(sup, self()),
  gen_server:start_link(?MODULE, [Emails], []).

%% ------------------------------------------------------------------
%% gen_server Function Definitions
%% ------------------------------------------------------------------

init(Emails) ->
  Accounts = store:get_accounts(Emails),
  Sockets = [inflow:serve_pool(As) || {_, As} <- Accounts ],
  {ok, Sockets}.

handle_call(_Request, _From, State) ->
  {reply, ok, State}.

handle_cast(_Msg, State) ->
  {noreply, State}.


handle_info({tcp_closed, _Socket}, S) ->
  {stop, normal, S};
handle_info({tcp_error, _Socket, _}, S) ->
  {stop, normal, S};
handle_info(_E, S) ->
  {noreply, S}.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%% ------------------------------------------------------------------
%% Internal Function Definitions
%% ------------------------------------------------------------------

