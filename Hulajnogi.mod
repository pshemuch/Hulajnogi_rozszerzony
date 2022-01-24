/*********************************************
 * OPL 20.1.0.0 Model
 * Author: pawelk
 * Creation Date: 20 gru 2021 at 17:10:06
 *********************************************/
 tuple Location
{
	key string name; 
	float x;
	float y;
	float happiness;
	float maxDistance;
	//int StationNum;
	int zapotrzebowanie;
};

{Location} ALLlocations = ...;

{Location} locations = {l| l in ALLlocations: l.zapotrzebowanie > 0};

tuple Route
{
  key string name;
  Location begin;
  Location end;
  int maxHulajnogi;
}

{Route} routes = ...;

tuple ShortestDistance
{
  Location begin;
  Location end;
  float distance;
}

{ShortestDistance} distances = ...;

tuple LocationToRoute
{
  Location location;
  Route route;
}

{LocationToRoute} locationToRoutes = {<l,r> | l in locations, r in routes}; 

int AllHulajnogi = ...;
float BigConst = ...;
//int AverageStationSize = ...; //round((sum(r in routes) r.maxHulajnogi)/card(routes));
//float NumOfStations = round(AllHulajnogi/AverageStationSize);


dvar float+ alfa[routes];
dvar float x[routes];
dvar float y[routes];
dvar boolean isStation[routes];
dvar boolean stationForLocation[locationToRoutes];
dvar float+ minDistanceToStat[locationToRoutes];
dvar boolean z1[locationToRoutes];
dvar boolean z2[locationToRoutes];
dvar float+ helper[locationToRoutes];

dexpr float stationsSum = sum(r in routes) isStation[r] * r.maxHulajnogi;
dexpr float statSumForLocation[l in locations] = sum (<l,r> in locationToRoutes) stationForLocation[<l,r>] * r.maxHulajnogi;

dexpr float locationHappiness[l in locations] = (sum (<l,r> in locationToRoutes) 
						((l.maxDistance * stationForLocation[<l,r>] - helper[<l,r>]) * l.happiness 
						* r.maxHulajnogi / l.zapotrzebowanie)) - 10 * (statSumForLocation[l] - l.zapotrzebowanie);


maximize sum(l in locations) locationHappiness[l];

subject to
{
  //stationsSum <= NumOfStations;
  stationsSum <= AllHulajnogi;
  
  forall(l in locations) zapotrz:
  		statSumForLocation[l] >= l.zapotrzebowanie;
  
  forall (r in routes, ltr in locationToRoutes: r == ltr.route) existingStations:
  		stationForLocation[ltr] <= isStation[r];
  
  //forall (l in locations) stationsNumber:
  //		statSumForLocation[l] == l.StationNum;
  		
  forall (ltr in locationToRoutes) oneRoute:
  		z1[ltr] + z2[ltr] == 1;
  
  forall (ltr in locationToRoutes, d in distances, s in distances: ltr.location == d.begin && 
  		ltr.route.begin == d.end && s.begin == d.end && ltr.route.end == s.end) lowerBound1:
  		minDistanceToStat[ltr] >= d.distance + s.distance * alfa[ltr.route] - z1[ltr] * BigConst;
  		
 
    forall (ltr in locationToRoutes, d in distances, s in distances: ltr.location == d.begin && 
  		ltr.route.end == d.end && s.end == d.end && ltr.route.begin == s.begin) lowerBound2:
  		minDistanceToStat[ltr] >= d.distance + s.distance * (1 - alfa[ltr.route]) - z2[ltr] * BigConst;

  	
  	forall (ltr in locationToRoutes) firstCons:
  		helper[ltr] <= BigConst * stationForLocation[ltr];
  	
  	forall (ltr in locationToRoutes) secondCons:
  		helper[ltr] <= minDistanceToStat[ltr];
  		
  	forall (ltr in locationToRoutes) thirdCons:
  		minDistanceToStat[ltr] - helper[ltr] + BigConst * stationForLocation[ltr] <= BigConst;
  	
  	forall (r in routes) stationX:
  		x[r] == r.begin.x * (1 - alfa[r]) + r.end.x * alfa[r];
  	
  	forall (r in routes) stationY:
  		y[r] == r.begin.y * (1 - alfa[r]) + r.end.y * alfa[r];
  	
  	forall (r in routes) properAlfa:
  		0 <= alfa[r] <= 1;
}
