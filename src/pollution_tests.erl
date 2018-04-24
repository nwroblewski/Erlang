%%%-------------------------------------------------------------------
%%% @author mikolaj
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. kwi 2018 00:42
%%%-------------------------------------------------------------------
-module(pollution_tests).
-author("mikolaj").
-include_lib("eunit/include/eunit.hrl").
-record(measure,{name,type,value,date}).
%% API



createMonitor_test() ->
  ?assertEqual(#{coords => #{},names => #{}, measures => []},pollution:createMonitor()).

addStation_test()->
  P = pollution:createMonitor(),
  P2 = pollution:addStation("Aleja Słowackiego", {50.2345, 18.3445}, P),
  ?assertEqual(#{coords => #{{50.2345, 18.3445} => "Aleja Słowackiego"},names => #{"Aleja Słowackiego" => {50.2345, 18.3445}}, measures => []},P2),
  ?assertEqual({error,"You can't add neither Name nor Coords that are already registered!"},pollution:addStation("Aleja Słowackiego", {50.2345, 18.3445}, P2)).

addValue_test()->
  P = pollution:createMonitor(),
  P2 = pollution:addStation("Aleja Słowackiego", {50.2345, 18.3445}, P),
  P4 = pollution:addValue({50.2345, 18.3445}, {{2018,4,23},{22,23,11}}, "PM10", 59, P2),
  ?assertEqual(#{coords => #{{50.2345, 18.3445} => "Aleja Słowackiego"},names => #{"Aleja Słowackiego" => {50.2345, 18.3445}}, measures => [{measure,"Aleja Słowackiego","PM10",59,{{2018,4,23},{22,23,11}}}]},P4).
removeValue_test()->
  P = pollution:createMonitor(),
  P2 = pollution:addStation("Aleja Słowackiego", {50.2345, 18.3445}, P),
  P4 = pollution:addValue({50.2345, 18.3445}, {{2018,4,23},{22,23,11}}, "PM10", 59, P2),
  P5 = pollution:removeValue("Aleja Słowackiego",{{2018,4,23},{22,23,11}},"PM10",P4),
  ?assertEqual(#{coords => #{{50.2345, 18.3445} => "Aleja Słowackiego"},names => #{"Aleja Słowackiego" => {50.2345, 18.3445}}, measures => []},P5),
  P6 = pollution:addValue({50.2345, 18.3445}, {{2018,4,23},{22,23,11}}, "PM10", 59, P5),
  P7 = pollution:removeValue({50.2345, 18.3445},{{2018,4,23},{22,23,11}},"PM10",P6),
  ?assertEqual(#{coords => #{{50.2345, 18.3445} => "Aleja Słowackiego"},names => #{"Aleja Słowackiego" => {50.2345, 18.3445}}, measures => []},P7).

getOneValue_test()->
  P = pollution:createMonitor(),
  P2 = pollution:addStation("Aleja Słowackiego", {50.2345, 18.3445}, P),
  P4 = pollution:addValue({50.2345, 18.3445}, {{2018,4,23},{22,23,11}}, "PM10", 59, P2),
  X = pollution:getOneValue("PM10",{{2018,4,23},{22,23,11}},"Aleja Słowackiego",P4),
  ?assertEqual(59,X).

getStationMean_test()->
  P = pollution:createMonitor(),
  P2 = pollution:addStation("Aleja Słowackiego", {50.2345, 18.3445}, P),
  P4 = pollution:addValue({50.2345, 18.3445}, {{2018,4,23},{22,23,11}}, "PM10", 59, P2),
  X = pollution:getStationMean("PM10","Aleja Słowackiego",P4),
  ?assertEqual(59.0,X).

getDailyMean_test()->
  P = pollution:createMonitor(),
  P2 = pollution:addStation("Aleja Słowackiego", {50.2345, 18.3445}, P),
  P4 = pollution:addValue({50.2345, 18.3445}, {{2018,4,23},{22,23,11}}, "PM10", 59, P2),
  P5 = pollution:addValue({50.2345, 18.3445}, {{2018,4,23},{21,23,11}}, "PM10", 72, P4),
  X = pollution:getDailyMean("PM10",{2018,4,23},P5),
  ?assertEqual(65.5,X).

getHourlyMean_test()->
  P = pollution:createMonitor(),
  P2 = pollution:addStation("Aleja Słowackiego", {50.2345, 18.3445}, P),
  P4 = pollution:addValue({50.2345, 18.3445}, {{2018,4,23},{22,23,11}}, "PM10", 59, P2),
  P5 = pollution:addValue({50.2345, 18.3445}, {{2018,4,23},{22,03,11}}, "PM10", 72, P4),
  P6 = pollution:addValue({50.2345, 18.3445}, {{2018,4,26},{22,13,11}}, "PM10", 82, P5),
  X = pollution:getHourlyMean("PM10",22,"Aleja Słowackiego",P6),
  ?assertEqual(71.0,X).