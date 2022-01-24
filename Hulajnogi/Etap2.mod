/*********************************************
 * OPL 20.1.0.0 Model
 * Author: pawelk
 * Creation Date: 21 gru 2021 at 02:00:56
 *********************************************/
tuple Location
{
	key string name; 
	float x;
	float y;
	float happiness;
	float maxDistance;
	int zapotrzebowanie;
};

{Location} locations = ...;

tuple Station
{
  key string name;
  float x;
  float y;
  int maxSize;
}

{Station} stations = ...;

tuple ShortestDistance
{
  Location location;
  Station station;
  float distance;
}

{ShortestDistance} distances = ...;



int AllHulajnogi = ...;

dvar int+ stationCap[stations];
dvar int+ demandPart[distances];

dexpr int hulajnogiSum = sum (s in stations) stationCap[s];
dexpr int demandPartSum[l in locations] = sum(<l,s,d> in distances) demandPart[<l,s,d>];

dexpr float locationHappiness[l in locations] = sum(<l,s,d> in distances) ((l.maxDistance - d) * demandPart[<l,s,d>] * l.happiness);

maximize sum(l in locations) locationHappiness[l];

subject to
{
  	hulajnogiSum <= AllHulajnogi;
  	
  	forall (s in stations) maxStationSize:
  		stationCap[s] <= s.maxSize;
  		
  	forall(s in stations, d in distances: s == d.station) maxPartSize:
  		demandPart[d] <= stationCap[s];
  		
  	forall(l in locations) demandSatisfied:
  		demandPartSum[l] == l.zapotrzebowanie;
  		
  	forall(s in stations) nonZeroCapacity:
  	1 <= stationCap[s];
  		
}