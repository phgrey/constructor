%%%-------------------------------------------------------------------
%%% @author phgrey
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%% Just a wrapper for underlying mysql process
%%% @end
%%% Created : 13. Feb 2016 19:40
%%%-------------------------------------------------------------------
-module(legacydb).
-author("phgrey").



%% API
-export([start_link/0]).

-import(mysql, []).
-import(lists, []).

%% gen_server callbacks
-export([get_emails/1, get_accounts/1]).

-define(SERVER, ?MODULE).

-include("messages.hrl").

-record(state, {}).


%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link() ->
  {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
  {ok, Creds} = application:get_env(sparker, dbpath),
  mysql:start_link(Creds ++ [{name, mysqlsrv}]).


%%%===================================================================
%%% query methods
%%%===================================================================

-spec get_emails(Count :: pos_integer()) -> [email()].
get_emails(Count)->
  {ok, _, Rows} = query("SELECT email FROM queue WHERE taken_by = 0 LIMIT ?", [Count]),
  lists:flatten(Rows).




-spec get_accounts(Emails :: [email()]) -> account().
get_accounts(Emails)->
  query("UPDATE queue SET taken_by = 1 WHERE email IN(" ++ questions(Emails) ++ ")", Emails),
  {ok, _, Rows} = query("SELECT a.email email, AES_DECRYPT(UNHEX(a.password_encrypted), UNHEX(?)) password, oauth_refresh_token
      UNHEX(t.push) token, s.type protocol, s.host host, s.port port, s.crypt crypt, s.additional
    FROM accounts a
    LEFT JOIN tokens t ON a.app_token = t.app
    LEFT JOIN mailservers s ON a.mailserver = s.hash
    WHERE a.email IN(" ++ questions(Emails) ++ ") AND a.status = 'OK'", [Emails]),
  Rows.



%%%===================================================================
%%% helper methods
%%%===================================================================

questions(Rows) ->
  lists:duplicate(length(Rows), "?").

%%spec(query(Sql :: string()) -> term() ).
query(Sql) ->
  query(Sql, []).
%%spec(query(Sql :: string(), Params :: list()) -> term() ).
query(Sql, Params) ->
  {ok, ColumnNames, Rows} = mysql:query(mysqlsrv, Sql, Params),
  {ColumnNames, Rows}.

%%convert(Resp) ->
%%  {mysql:get_result_field_info(Resp), mysql:get_result_rows(Resp)}.