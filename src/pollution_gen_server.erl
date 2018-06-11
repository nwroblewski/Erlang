%%%-------------------------------------------------------------------
%%% @author mikolaj
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. maj 2018 12:08
%%%-------------------------------------------------------------------
-module(pollution_gen_server).
-author("mikolaj").

%% API
-export([
  start_link/0,
  init/1,
  stop/0,
  addStation/2,
  handle_call/3,
  getMonitor/0,
  addValue/4,
  removeValue/3,
  handle_cast/2,
  getOneValue/3,
  getStationMean/2,
  getDailyMean/2,
  getHourlyMean/3,
  crash/0
]).

%START%
start_link()->gen_server:start_link({local,server},?MODULE,[],[]).

init(_)->
  {ok,pollution:createMonitor()}.

stop()->
  server ! stop.
%% CLIENT -> SERVER INTERFACE %%

getMonitor() ->
  gen_server:call(server,getMonitor).

addStation(Name,{X,Y} = Coords)->
  gen_server:call(server,{Name,Coords,addStation}).

addValue(Coords_Name,Date,Type,Value)->
  gen_server:call(server,{Coords_Name,Date,Type,Value,addValue}).

removeValue(Coords_Name,Date,Type)->
  gen_server:cast(server,{Coords_Name,Date,Type,removeValue}).

getOneValue(Type,Date,Name)->
  gen_server:call(server,{Type,Date,Name,getOneValue}).

getStationMean(Type,Name)->
  gen_server:call(server,{Type,Name,getStationMean}).

getDailyMean(Type,{_,_,_} = Day)->
  gen_server:call(server,{Type,Day,getDailyMean}).

getHourlyMean(Type,Hour,Name)->
  gen_server:call(server,{Type,Hour,Name,getHourlyMean}).

crash()->
  gen_server:cast(server,{crash}).


%% HANDLERS %%

handle_call(getMonitor,_From,Monitor)->
  {reply,Monitor,Monitor};

handle_call({Name,Coords,addStation},_From,{ok,Monitor})->
  Check = pollution:addStation(Name,Coords,Monitor),
  case Check of
    {ok,NewMonitor} -> {reply,ok,NewMonitor};
    {error,_} -> {reply,Check,Monitor}
  end;

handle_call({Name,Coords,addStation},_From,Monitor)->
  Check = pollution:addStation(Name,Coords,Monitor),
  case Check of
    {ok,NewMonitor} -> {reply,ok,NewMonitor};
    {error,_} -> {reply,Check,Monitor}
  end;

handle_call({Coords_Name,Date,Type,Value,addValue},_From,{ok,Monitor})->
  Check = pollution:addValue(Coords_Name,Date,Type,Value,Monitor),
  case Check of
    {ok,NewMonitor} -> {reply,ok,NewMonitor};
    {error,_} -> {reply,Check,Monitor}
  end;

handle_call({Coords_Name,Date,Type,Value,addValue},_From,Monitor)->
  Check = pollution:addValue(Coords_Name,Date,Type,Value,Monitor),
  case Check of
    {ok,NewMonitor} -> {reply,ok,NewMonitor};
    {error,_} -> {reply,Check,Monitor}
  end;


%% TODO Function getOneValue needs refactorization in pollution.erl %%

handle_call({Type,Date,Name,getOneValue},_From,{ok,Monitor})->
  {reply,{ok,pollution:getOneValue(Type,Date,Name,Monitor)},Monitor};

handle_call({Type,Date,Name,getOneValue},_From,Monitor)->
  {reply,{ok,pollution:getOneValue(Type,Date,Name,Monitor)},Monitor};


handle_call({Type,Name,getStationMean},_From,{ok,Monitor})->
  Check = pollution:getStationMean(Type,Name,Monitor),
  case Check of
    {ok,X} -> {reply,X,Monitor};
    {error,_} -> {reply,Check,Monitor}
  end;

handle_call({Type,Name,getStationMean},_From,Monitor)->
  Check = pollution:getStationMean(Type,Name,Monitor),
  case Check of
    {ok,X} -> {reply,X,Monitor};
    {error,_} -> {reply,Check,Monitor}
  end;

handle_call({Type,{_,_,_} = Day,getDailyMean},_From,{ok,Monitor})->
  {reply,pollution:getDailyMean(Type,Day,Monitor),Monitor};

handle_call({Type,{_,_,_} = Day,getDailyMean},_From,Monitor)->
  {reply,pollution:getDailyMean(Type,Day,Monitor),Monitor};

handle_call({Type,Hour,Name,getHourlyMean},_From,{ok,Monitor})->
  {reply,pollution:getHourlyMean(Type,Hour,Name,Monitor),Monitor};

handle_call({Type,Hour,Name,getHourlyMean},_From,Monitor)->
  {reply,pollution:getHourlyMean(Type,Hour,Name,Monitor),Monitor}.

handle_cast({Coords_Name,Date,Type,removeValue},{ok,Monitor})->
  {noreply,pollution:removeValue(Coords_Name,Date,Type,Monitor)};

handle_cast({Coords_Name,Date,Type,removeValue},Monitor)->
  {noreply,pollution:removeValue(Coords_Name,Date,Type,Monitor)};

handle_cast({crash},Monitor)->
  X = 1/0,
  {noreply,Monitor}.
