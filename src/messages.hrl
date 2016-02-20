%% Data used in application
%% inspired by
%% http://learnyousomeerlang.com/dialyzer
%% http://erlang.org/doc/programming_examples/records.html#id59193
%% http://erlang.org/doc/reference_manual/typespec.html


%%%% CACHEABLE DATA - for plain db
%primary types
-type protocol() :: ews|imap|smtp|apn.

-type email() :: atom() | {atom()} | {atom(), protocol()}.

% for push token
-type push_token() :: <<_:50>>.

%%secondary types, almost records

%% probably divide in in_server / out_server by protocols?
-record(server, {protocol::protocol(), host :: atom(), port :: pos_integer(), crypt :: plain|ssl|startls }).
-type server() :: #server{}.

-type auth() :: { plain, Login :: atom(), Pass :: atom() }
              | { oauth, Access ::binary(), Refresh :: binary()}
              | { cert, Certificate :: binary }.


-type credentials() ::  {Server :: server(), Auth :: auth(), Additional :: #{}}.

%spark account meaning
-record(account, {email::email(), token :: push_token(), creds :: credentials() }).
-type account() :: #account{}.

%%%%% some recursive structure for fun and tree building

-record(linking, {own::push_token()|email(), other::linking(), creds :: credentials()}).
-type linking() :: #linking{}.

%%%typed tree
%%-type link2typed() :: {OwnType :: device|account, linking()}.
%%some strange fucking shit
%%-record(device_account, {token :: push_token(), email_accounts = [] :: [email_account()] }).
%%-record(email_account, {email::email(), device_accounts = [] :: [device_account()] }).
%%few more datatypes - dunno why
%%-record(link2device, {token::push_token(), creds :: credentials()}).
-type link2device() :: {Token ::push_token(), Creds :: credentials()}.
%%-record(link2email, {email::email(), creds :: credentials() }).
%%-type link2email() :: #link2email{}.
%%-record(device_account, {token :: push_token(), emails = [] :: [link2email()] }).
%%-type device_account() :: #device_account{}.
%%-record(email_account, {email::email(), devices = [] :: [link2device()] }).
%%-type email_account() :: #email_account{}.

-type in_pipe() :: { pid(), email(), Devices :: [link2device()] }.