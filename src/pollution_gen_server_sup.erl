%%%-------------------------------------------------------------------
%%% @author mikolaj
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. cze 2018 00:44
%%%-------------------------------------------------------------------
-module(pollution_gen_server_sup).
-author("mikolaj").
-behaviour(supervisor).

%% API
-export([
  start_link/0,
  init/1
]).


start_link()->
  supervisor:start_link({local,supervisor},?MODULE,[]).

init(_InitialValue)->
  {ok, {
    {one_for_all,2,3},
    [{pollutionServer,
      {pollution_gen_server,start_link,[]},
      permanent,brutal_kill,worker,[pollution_gen_server]}
    ]}
  }.