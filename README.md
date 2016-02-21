## Why/to try:
1. observer - http://erlang.org/doc/apps/observer/observer_ug.html
2. ditributed
3. erts - http://erlang.org/doc/apps/erts/communication.html
console in the app namespace

## HOWTO
- run: http://stackoverflow.com/questions/16675767/how-to-run-erlang-rebar-build-application :
    erl -pa ebin | rebar3 shell
    1> application:start(constructor).


### TODOs:
- add a config
- think about own, non-erlang standard email processes registration
- move servers oauth credentials to a small config singleton instance
- howto extend