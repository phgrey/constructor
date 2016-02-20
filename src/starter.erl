%% timer checker, copied from http://stackoverflow.com/a/17849176

-module(starter).
-behaviour(gen_server).
-define(SERVER, ?MODULE).

%% ------------------------------------------------------------------
%% API Function Exports
%% ------------------------------------------------------------------

-export([start_link/0]).

%% ------------------------------------------------------------------
%% gen_server Function Exports
%% ------------------------------------------------------------------

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).


-include("messages.hrl").

-import(poolboy, []).
-import(jsx, []).
%% ------------------------------------------------------------------
%% API Function Definitions
%% ------------------------------------------------------------------

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%% ------------------------------------------------------------------
%% gen_server Function Definitions
%% ------------------------------------------------------------------

init([]) ->
    Timer = erlang:send_after(1, self(), check),
    {ok, Timer}.

handle_info(check, OldTimer) ->
  erlang:cancel_timer(OldTimer),
  manager(),
  Timer = erlang:send_after(1000, self(), check),
  {noreply, Timer}.

%%generated code

handle_call(_Request, _From, State) ->
  {reply, ok, State}.

handle_cast(_Msg, State) ->
  {noreply, State}.


terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% ------------------------------------------------------------------
%% Internal Function Definitions
%% ------------------------------------------------------------------

manager() ->
  Emails = cache:get_emails(100),
%% convertation is obsolette here
%%  [list_to_atom(X)||X <- Emails];
  if
    length(Emails) > 0 ->
      Rows = cache:get_accounts(Emails),
      Accounts = [account_from_db(X) || X <- Rows];
    true -> []
  end.

account_from_db(DbData)->
  {Email, Password, OauthRefresh, Token, Protocol, Host, Port, Crypt, ServerAddJSON} = DbData,
  Server = #server{protocol = list_to_atom(Protocol), host = list_to_atom(Host), port=Port, crypt = list_to_atom(Crypt)},
  %%TODO: more complicated, add servertype check and throw if type is wrong. Also Adds should be checked
  Auth = if
           OauthRefresh == [] ->  { plain, Email, Password};
           Password == [] ->   { oauth, <<>>, OauthRefresh}
         end,
  Add = jsx:decode(ServerAddJSON),
  #account{email = list_to_atom(Email), token = list_to_binary(Token), creds={Server, Auth, Add} }.