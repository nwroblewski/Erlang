%%%-------------------------------------------------------------------
%%% @author mikolaj
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. maj 2018 01:24
%%%-------------------------------------------------------------------
-module(pollution_server).
-author("mikolaj").

%% API
-export([
  start/0,
  stop/0,
  getHourlyMean/3,
  getDailyMean/2,
  getStationMean/2,
  getOneValue/3,
  getMonitor/0,
  addStation/2,
  addValue/4,
  removeValue/3
]).


start()->
  Monitor = pollution:createMonitor(),
  PID = spawn(fun()->loop(Monitor) end),
  register(server,PID).

stop()->
  server ! stop,
  unregister(server).


loop(Monitor)->
  receive
    {Pid,getMonitor} -> Pid ! {ok,Monitor},loop(Monitor);
    {Pid,stop} -> Pid ! ok;
    {Pid,addStation,Name,Coords} ->
      Check = pollution:addStation(Name,Coords,Monitor),
      Pid ! getState(Check),
      case Check of
        {ok,NewMonitor} -> loop(NewMonitor);
        _ -> loop(Monitor)
      end;
    {Pid,addValue,Name_Coords,Date,Type,Value} ->
      Check = pollution:addValue(Name_Coords,Date,Type,Value,Monitor),
      Pid ! getState(Check),
      case Check of
        {ok,NewMonitor} -> loop(NewMonitor);
        _ -> loop(Monitor)
      end;
    {Pid,removeValue,Name_Coords,Date,Type}->
      Check = pollution:removeValue(Name_Coords,Date,Type,Monitor),
      Pid ! getState(Check),
      case Check of
        {ok,NewMonitor} -> loop(NewMonitor);
        _ -> loop(Monitor)
      end;
    {Pid,getOneValue,Type,Date,Name}->
      Check = pollution:getOneValue(Type,Date,Name,Monitor),
      Pid ! Check,
      loop(Monitor);
    {Pid,getStationMean,Type,Name}->
      Check = pollution:getStationMean(Type,Name,Monitor),
      Pid ! Check,
      loop(Monitor);
    {Pid,getDailyMean,Type,Day}->
      Check = pollution:getDailyMean(Type,Day,Monitor),
      Pid ! Check,
      loop(Monitor);
    {Pid,getHourlyMean,Type,Hour,Name}->
      Check = pollution:getHourlyMean(Type,Hour,Name,Monitor),
      Pid ! Check,
      loop(Monitor)
  end.

getState({ok,Monitor})->ok;
getState({error,ErrorMessage}) -> {error,ErrorMessage};
getState(_)->{error,"Internal server error occured"}.

getMonitor() -> server ! {self(),getMonitor},responseHandler().
addStation(Name,Coords) -> server ! {self(),addStation,Name,Coords}, responseHandler().
addValue(Name_Coords,Date,Type,Value) -> server ! {self(),addValue,Name_Coords,Date,Type,Value},responseHandler().
removeValue(Name_Coords,Date,Type) -> server ! {self(),removeValue,Name_Coords,Date,Type},responseHandler().
getOneValue(Type,Date,Name)-> server ! {self(),getOneValue,Type,Date,Name},responseHandler().
getStationMean(Type,Name)-> server !{self(),getStationMean,Type,Name},responseHandler().
getDailyMean(Type,Day)-> server !{self(),getDailyMean,Type,Day},responseHandler().
getHourlyMean(Type,Hour,Name) -> server !{self(),getHourlyMean,Type,Hour,Name},responseHandler().

responseHandler()->
  receive
    ok -> ok;
    {ok,Value} -> {ok,Value};
    {error,ErrorMessage} -> {error,ErrorMessage};
    X -> X
  after
  1000->{error,"There was no data provided."}
  end.