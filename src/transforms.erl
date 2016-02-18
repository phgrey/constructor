%%%-------------------------------------------------------------------
%%% @author phgrey
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. Feb 2016 19:00
%%%-------------------------------------------------------------------
-module(transforms).
-author("phgrey").

%% API
-export([pipe_me_in/1]).

-include("messages.hrl").

-import(in_pipe, [start_link/1]).
%%%% part1 - from client's http request to established incoming port

%%% helpers

%%TODO: implement
-spec(pipe_me_in(iolist() ) -> account()).
parse_account(Req) ->
  #account{email = list_to_atom(Req)}.

%%TODO: this is a robustivity test for erlang))))
%%single observer, tonns of global names - fixit!
-spec(get_pipe(atom)->port()).
get_pipe(Email)->
  case whereis(Email) of
    undefined ->
      inflow:start_pipe(Email);
    Pid ->
      Pid
  end.

-spec(pipe_me_in(iolist() | account()) -> in_pipe()).
pipe_me_in(Req) when is_list(Req) ->
  {ok, Account} = parse_account(Req),
  pipe_me_in(Account);
pipe_me_in(Acc) when is_record(Acc, account) ->
  P = get_pipe(Acc#account.email),
  P ! {account, Acc}.