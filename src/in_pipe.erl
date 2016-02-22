%%%-------------------------------------------------------------------
%%% @author phgrey
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%  https://github.com/archaelus/erlmail - 8y
%%%  https://github.com/boorad/erlimap - 4y, .dot
%%%  https://github.com/corecode/eimap - 3y, lisp, macro, !!!!, 3/1/1
%%%
%%%  https://git.kolab.org/diffusion/EI/ - right now - so-so, command is behaviour
%%%  https://github.com/RYTong/erlmail-client - 3y - BAD
%%%
%%%  https://github.com/vagabond/diemap - peg, neotomna (https://github.com/seancribbs/neotoma), SERVER
%%%
%%%  This is a wrappper around email process. Mostly code here is runned inside worker process. Later we'll be able
%%% to choose listening type here according to an account type
%%%

%%% @end
%%% Created : 11. Feb 2016 8:20
%%%-------------------------------------------------------------------
-module(in_pipe).
-author("phgrey").

-include("messages.hrl").

-import(gen_tcp, []).
-import(ssl, []).
-import(maps, []).

-export([start/1]).

%% ------------------------------------------------------------------
%% Public
%% ------------------------------------------------------------------


start({Server, Auth, Add})->
  {ok, Sock} = create_socket(Server, socket_options(Add)).







%% ------------------------------------------------------------------
%% Private
%% ------------------------------------------------------------------

socket_options(#{nasty_ssl := true}=Add) ->
  [{verify, verify_none}] ++ socket_options(maps:remove(nasty_ssl, Add));
socket_options(_Add) ->
  [binary, { active, once }, { send_timeout, 5000 }].


create_socket(#server{crypt=ssl, host=Host, port=Port}, Options)->
  ssl:connect(Host, Port, Options);

create_socket(#server{crypt=_, host=Host, port=Port}, Options) ->
  gen_tcp:connect(Host, Port, Options).

