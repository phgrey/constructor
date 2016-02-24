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
-export([parse_account/1, accounts_to_in_pipe/1]).

-include("messages.hrl").

-import(jsx, [decode/1]).

%%%% part1 - from client's http request to established incoming port

%%% helpers

-spec(parse_account({legacydb|http, Data :: term()}) -> account()).
parse_account({legacydb, DbData})->
  {Email, Password, OauthRefresh, Token, Protocol, Host, Port, Crypt, ServerAddJSON} = DbData,
  Server = #server{protocol = list_to_atom(Protocol), host = list_to_atom(Host), port=Port, crypt = list_to_atom(Crypt)},
  %%TODO: more complicated, add servertype check and throw if type is wrong. Also Adds should be checked
  Auth = if
           OauthRefresh == [] ->  { plain, Email, Password};
           Password == [] ->   { oauth, <<>>, OauthRefresh}
         end,
  Add = jsx:decode(ServerAddJSON),
  #account{email = list_to_atom(Email), token = list_to_binary(Token), creds={Server, Auth, Add} };
parse_account({http, Req}) ->
  #account{email = list_to_atom(Req)}.

-spec accounts_to_in_pipe(Accounts :: [account()])->in_pipe().
accounts_to_in_pipe([#account{email=Email, token=Token, creds=Creds }|Oher])->
  Devices = [{Token, Creds}] ++ [{T, C} || #account{email=Email, token=T, creds=C } <- Oher ],
  #in_pipe{email=Email, token=Token, devices = Devices}.

