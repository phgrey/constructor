%%%-------------------------------------------------------------------
%%% @author phgrey
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. Feb 2016 20:21
%%%-------------------------------------------------------------------
-module(store).
-author("phgrey").


-import( ets,[]).

-include("messages.hrl").
-import(transforms, []).
-import(legacydb, []).


%% API
-export([get_accounts/1, register_pipes/2, locate_pipe/1]).

-on_load(create_tables/0).

-spec get_accounts([email()])->[{email(), [account()]}].
get_accounts(Emails)->
  register_pipes(self(), Emails),
  Accounts = [transforms:parse_account(legacydb, Row) || Row <- legacydb:get_accounts(Emails)],
  maps:to_list(group_accounts(Accounts)).


group_accounts(Accounts)->
  lists:foldl(fun(El, AccIn)->
                Email = El#account.email,
                maps:put(Email, maps:get(Email, AccIn, []) ++ [El], AccIn)
              end, #{}, Accounts).



%%%===================================================================
%%% Pipes/pid finding
%%%===================================================================


create_tables() ->
  ets:new(in_pipes).

register_pipes(Pid, Emails)->
  ets:insert(in_pipes, [{E, Pid} || E <-Emails]).

locate_pipe(Email)->
  case ets:lookup(in_pipes, Email) of
    [] -> undefined;
    [{_, Pid}] -> Pid
  end.