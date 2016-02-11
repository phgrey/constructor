%%%-------------------------------------------------------------------
%%% @author phgrey
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% https://habrahabr.ru/post/195542/
%%% http://www.erlang.org/course
%%%
%%% @end
%%% Created : 11. Feb 2016 2:10

%%%-------------------------------------------------------------------
-module(first).
-author("phgrey").

%% API
-export([add/2, subtr/2, same/2, greet/2, first/1, second/1, bmi_tell/1, lucky_number/1, safe_division/2, if_bmi_tell/1, assessment_of_temp/1]).

%% Simple functions

add(X, Y) ->
  X + Y.

subtr(X, Y) -> X - Y.

%% pattern matching

greet(male, Name) ->
  io:format("Hello, Mr. ~s!", [Name]);
greet(female, Name) ->
  io:format("Hello, Mrs. ~s!", [Name]);
greet(_, Name) ->
  io:format("Hello, ~s!", [Name]).

first([X|_]) -> X.
second([_,X|_]) -> X.

same(X,X) ->
  true;
same(_,_) ->
  false.

%% guards

bmi_tell(Bmi) when Bmi =< 18.5 ->
  "You're underweight.";
bmi_tell(Bmi) when Bmi =< 25 ->
  "You're supposedly normal.";
bmi_tell(Bmi) when Bmi =< 30 ->
  "You're fat.";
bmi_tell(_) ->
  "You're very fat.".


lucky_number(X) when 10 < X, X < 20 -> %"," mean AND, or even andalso
  really;
lucky_number(X) when 10 > X; X < 20 -> %";" mean OR, or even orelse
  almost;
lucky_number(_) ->
  never.

safe_division(X, Y) when is_integer(X), is_integer(Y), Y /= 0 ->
  X / Y;
safe_division(_, _) ->
  false.


%% if
if_bmi_tell(Bmi) ->
  if Bmi =< 18.5 -> "You're underweight.";
    Bmi =< 25   -> "You're supposedly normal.";
    Bmi =< 30   -> "You're fat.";
    true        -> "You're very fat."
  end.

assessment_of_temp(Temp) ->
  case Temp of
    {X, celsius} when 20 =< X, X =< 45 ->
      'favorable';
    {X, kelvin} when 293 =< X, X =< 318 ->
      'scientifically favorable';
    {X, fahrenheit} when 68 =< X, X =< 113 ->
      'favorable in the US';
    _ ->
      'not the best tempperature'
  end.