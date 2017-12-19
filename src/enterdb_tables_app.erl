%%%===================================================================
%% @author Jonas Falkevik
%% @copyright 2017 Pundun Labs AB
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%% http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
%% implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%% -------------------------------------------------------------------
%% @title
%% @doc
%% Module Description:
%% @end
%%%===================================================================

-module(enterdb_tables_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

-include_lib("gb_log/include/gb_log.hrl").

%% ===================================================================
%% Application callbacks
%% ===================================================================
start(_StartType, _StartArgs) ->
    ?debug("About to open all tables."),
    open_all_tables().

stop(_State) ->
    ok.
%%--------------------------------------------------------------------
%% @doc
%% Open existing database table shards.
%% @end
%%--------------------------------------------------------------------
-spec open_all_tables() -> ok | {error, Reason :: term()}.
open_all_tables() ->
    case enterdb_db:transaction(fun() -> mnesia:all_keys(enterdb_table) end) of
	{atomic, TableList} ->
	    lists:foreach(fun open_table/1, TableList),
	    enterdb_tables_sup:start_link();
	{error, Reason} ->
	    {error, Reason}
    end.
open_table(Table) ->
    try
	enterdb_lib:do_open_table(Table)
    catch C:E ->
	?warning("could not open table ~p ~p:~p ~p",
	    [Table, C, E, erlang:get_stacktrace()])
    end.
