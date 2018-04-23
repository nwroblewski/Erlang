%%%-------------------------------------------------------------------
%%% @author mikolaj
%%% @doc
%%%
%%% @end
%%% Created : 22. kwi 2018 14:25
%%%-------------------------------------------------------------------
-module(pollution).
-author("mikolaj").

%% API
-export([createMonitor/0,addValue/5,addStation/3,removeValue/4,getOneValue/4,getStationMean/3,getDailyMean/3,getHourlyMean/3]).
-record(measure,{name,type,value,date}).

createMonitor() ->
  #{coords => #{},names => #{}, measures => []}.  % to be honest I don't have better idea than this redundancy


addStation(Name,{X,Y},#{coords := Coords,names := Names } = Monitor)
  when is_list(Name) and is_number(X) and is_number(Y) ->
    case maps:is_key(Name,Names) or maps:is_key({X,Y},Coords) of
      false -> Monitor#{coords => Coords#{{X,Y} => Name},names => Names#{Name => {X,Y}}};
      true -> {error,"You can't add neither Name nor Coords that are already registered!"}
    end.


addValue({_,_} = Coord,Date,Type,Value,#{coords := Coords} = Monitor) ->
  case maps:is_key(Coord,Coords) of
    true -> addValue(maps:get(Coord,Coords),Date,Type,Value,Monitor);
    false -> {error,"You can't add measure to Station which such coordinates, because it doesn't exist in provided Monitor!"}
  end;

addValue(Name,Date,Type,Value,#{names := Names, measures := Measures } = Monitor) ->
  case maps:is_key(Name,Names) of
    true -> Monitor#{measures => [#measure{name = Name,type = Type,value = Value,date = Date}|Measures]};
    false -> {error,"There is no station with such name!"} %this one won't actually ever happen, but it needs to be here :/
  end.


removeValue({_,_} = Coord,Date,Type,#{coords := Coords} = Monitor) ->
  case maps:is_key(Coord,Coords) of
    true -> removeValue(maps:get(Coord,Coords),Date,Type,Monitor);
    false -> {error,"You can't delete measuere from non-existing station!"}
  end;
removeValue(Name,Date,Type,#{measures := Measures} = Monitor) ->
  Monitor#{measures => lists:filter(fun(X) -> removingFilter(X,Name,Date,Type) end , Measures)}.

removingFilter(X,Name,Date,Type) ->  %X is a record of type measure
  not (X#measure.date == Date andalso X#measure.type == Type andalso X#measure.name == Name).


getOneValue(Type,Date,Name,#{names:= Names, measures := Measures}) ->
  case maps:is_key(Name,Names) of
    true -> [H|_] = lists:filter(fun(X) -> X#measure.name == Name andalso X#measure.type == Type andalso X#measure.date == Date end, Measures),
      {H#measure.type,H#measure.value,H#measure.date};
    false -> "There is no station with such name!"
  end.


getStationMean(Type, Name, #{names := Names,measures := Measures}) ->
  case maps:is_key(Name,Names) of
    true -> meanHelper(lists:filter(fun(X) -> X#measure.type == Type andalso X#measure.name == Name end,Measures));
    false -> {error,"There is no station with such name!"}
  end.
meanHelper([]) -> 0;

meanHelper([H|T]) ->
  lists:foldl(fun(X,Acc) -> X + Acc end,0,lists:map(fun(X) -> X#measure.value end,[H|T]))/length([H|T]).


getDailyMean(Type, Day, #{measures := Measures})->
  case meanHelper(lists:filter(fun(X) -> X#measure.type == Type andalso element(1,X#measure.date) == Day end,Measures)) of
    0 -> {error,"No measures of this type were saved at this day."};
    X -> X
  end.

getHourlyMean(Type,Hour,#{measures := Measures}) ->
  case meanHelper(lists:filter(fun(X) -> X#measure.type == Type andalso element(1,element(2,X#measure.date)) == Hour end,Measures)) of
    0 -> {error,"No measures of this type were saved at this particular hour at any day."};
    X -> X
  end.