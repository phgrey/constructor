%%%-------------------------------------------------------------------
%%% @author phgrey
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%% Just a wrapper for underlying mysql process
%%% @end
%%% Created : 13. Feb 2016 19:40
%%%-------------------------------------------------------------------
-module(cache).
-author("phgrey").



%% API
-export([start_link/0]).

-import(mysql, []).
-import(lists, []).

%% gen_server callbacks
-export([get_emails/1]).

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


-spec get_account(Email :: email()) -> account().
get_account(Email)->
  {ok, _, Rows} = query("SELECT UNHEX(t.push) token, a.email email,
    FROM accounts a
    LEFT JOIN tokens t ON a.app_token = t.push
    LEFT JOIN mailservers s ON a.mailserver = s.push
    WHERE a.email = ? AND a.status = 'OK'", [Email]),



%%spec(query(Sql :: string()) -> term() ).
query(Sql) ->
  query(Sql, []).
%%spec(query(Sql :: string(), Params :: list()) -> term() ).
query(Sql, Params) ->
  {ok, ColumnNames, Rows} = mysql:query(mysqlsrv, Sql, Params),
  {ColumnNames, Rows}.

%%convert(Resp) ->
%%  {mysql:get_result_field_info(Resp), mysql:get_result_rows(Resp)}.