/**
* Name: Route_38
* Route 38 example 
* Author: jonat
* Tags: 
*/


model Route_38

global {
	
	file route_38_bounds <- shape_file("../includes/Route_38_Stops.shp");
	
	geometry shape <- envelope(route_38_bounds);
	
	init {
		create stops from:csv_file( "../includes/stops.csv",true) with:
				[
				stop_name::string(get("stop_name")),
				lon::float(get("stop_lon")),
				lat::float(get("stop_lat"))
			];	
	}
}


species stops {
	string stop_name;
	rgb color ;
	float lon;
	float lat;
	point coordinate;
	
	init{
		coordinate <- point({lon, lat});
		location <- point(to_GAMA_CRS(coordinate));
	}
	
	aspect base {
		draw circle(0.0004) color: #yellow border: #black;
	}
}

experiment main type: gui{
	output {
		display map {
			species stops aspect: base;
		}
		}
		}
		