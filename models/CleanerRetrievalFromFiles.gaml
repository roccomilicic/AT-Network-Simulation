/**
* Name: CleanerRetrievalFromFiles
* Reading and writing data from our gtfs files for multiple routes whilst using the same files to store data for all routes stops, stop times, etc ...
 
* Author: jonat
* Tags: 
*/


model CleanerRetrievalFromFiles

global{
	//Files
	file bounds <- shape_file("../includes/Route_38_Stops.shp");
	file stops_csv <- csv_file("../includes/stops38_35.csv", ",");
	file roads_csv <- csv_file("../includes/gtfs_route_38_35.csv", ",");
	file routes_csv <- csv_file("../includes/routes.csv");
	file all_bus_trips <- csv_file("../includes/single_trip_Route38.csv");
	file multiple_route_38_trips <- csv_file("../includes/stop_times_multiple_Route38.csv");
	
	
	//Graph for buses to follow
	list<graph> graphs;
	list<string> graph_names; 
	
	//Bounds
	geometry shape <- envelope(bounds);

	// Variables for the clock species
	date starting_date <- date([2024, 8, 12, 4, 42, 0]);
	float step <- 1 #second;
	
	
	
	// Route matrixes for CSV route_38_roads
	matrix roads <- matrix(roads_csv);
	matrix stops <- matrix(stops_csv);
	matrix routes <- matrix(routes_csv);

	// Bus routes
	matrix trips_matrix <- matrix(all_bus_trips);
	matrix route_38_multiple_trip_matrix <- matrix(multiple_route_38_trips);
	//string first_departure_time <- route_38_trip_matrix[2, 0];
	list<string> bus_start_times <- [];
	int next_bus_index <- 0; // Index to keep track of the next bus to create
	init {
		create clock {
			current_date <- starting_date;
			}
		
		create stop from: stops_csv with: [stop_id::string(get("stop_id")), stop_name::string(get("stop_name")), lon::float(get("stop_lon")), lat::float(get("stop_lat"))];
		
		
		// Create roads of the bus route from the CSV file route_38_roads
		loop row from: 1 to: roads.rows - 2 { // Iterate through rows, stopping at the second to last row
		//write "\nProcessing row: " + row;
			float lon1 <- roads[2, row]; // Longitude for the current row
			float lat1 <- roads[1, row]; // Latitude for the current row
			float lon2 <- roads[2, row + 1]; // Longitude for the next row
			float lat2 <- roads[1, row + 1]; // Latitude for the next row

			string shape_id <- roads[0, row];
			string shape_id_next <- roads[0, row + 1];

			// Create road species based on collected route_38_roads from CSV
			create road {
			// Lon and lat values for current point 
				
				if (shape_id = shape_id_next) {
					
					road_shape_id <- shape_id;
					
					lon <- lon1;
					lat <- lat1;

					// Location for the current point to put the beginning of the road on the map
					coordinate <- point({lon, lat});
					location <- point(to_GAMA_CRS(coordinate));

					// Lon and lat values for next point
					lon_next <- lon2;
					lat_next <- lat2;

					// Location for the next stop to put the beginning of the road on the map
					point next_coordinate <- point({lon_next, lat_next});
					point next_location <- point(to_GAMA_CRS(next_coordinate));
				}
				
				else {
					shape_id <- shape_id_next;
					
					road_shape_id <- shape_id;
					
					lon <- lon1;
					lat <- lat1;

					// Location for the current point to put the beginning of the road on the map
					coordinate <- point({lon, lat});
					location <- point(to_GAMA_CRS(coordinate));

					// Lon and lat values for next point
					lon_next <- lon2;
					lat_next <- lat2;

					// Location for the next stop to put the beginning of the road on the map
					point next_coordinate <- point({lon_next, lat_next});
					point next_location <- point(to_GAMA_CRS(next_coordinate));
					
				}

				// Link the 2 stops together
				//next_road_link <- line(next_location, next_location);
			}
		
		}
		
		//the_graph <- as_edge_graph(road); // Create graph for all road points
		loop row from: 1 to: routes.rows - 1 {
			string current_route <- routes[3, row];
			string current_route_id <- routes[0, row];
			add current_route to: graph_names;
			
			bool trip_found <- false;
			int trip_row <- 1;
			string route_shape_id;
			
			loop while: trip_found = false {
				if(trips_matrix[trip_row, 0] = current_route_id)
				{
					trip_found <- true;
					route_shape_id <- trips_matrix[trip_row, 7];
				}
				else
				{
					trip_row <- trip_row + 1;
				}
			}
			
			road current_road;
			
			
			
		}
		
	
	}
}





//Species Declarations

species stop {
	string stop_id;
	string stop_name;
	rgb color;
	float lon;
	float lat;
	point coordinate;

	init {
		coordinate <- point({lon, lat});
		location <- point(to_GAMA_CRS(coordinate));
	}

	aspect base {
		draw circle(0.0004) color: #yellow border: #black;
	}

}

species road {
	rgb color;
	float lon;
	float lat;
	float lon_next;
	float lat_next;
	point coordinate;
	geometry next_road_link;
	string road_shape_id;

	aspect base {
		draw shape color: #red;
		draw next_road_link color: #pink;
	}

}

species bus skills: [moving] {
	point coordinate;
	path path_following <- list(the_graph) as_path the_graph;
	string trip_id;
	list<string> stop_departure_times;
	list<string> stop_arrival_times;
	list<float> bus_speeds;

	reflex myfollow {
		int bus_stop <- 0;
		loop i from: 0 to: length(stops) - 1 { // Each route point within the route (makes up the road)
			float speed_to_next_stop <- bus_speeds at bus_stop * 0.53; // Save speed of bus depending on arrival stop
			//write "\nCURRENT STOP: " + bus_stop;
			if string(current_date, " HH:mm:ss") >= " " + stop_departure_times at bus_stop { // If clock passes bus stop time
				bus_stop <- bus_stop + 1; // Incremenet bus stop number
				//write "\nLooping stop: " + bus_stop + " @ " + stop_departure_times at bus_stop;
				//write "Current speed for this segment: " + speed_to_next_stop + " m/s";

			}

			do follow path: path_following speed: speed_to_next_stop; // follow the path with given speed for current bus stop

		}

	}

	aspect base {
		draw rectangle(0.0005, 0.001) color: #blue border: #black; // Draw the bus
		loop seg over: path_following.edges {
			draw seg color: color;
		}

	}

}

species clock {
	date current_date update: date(cycle * step);
	string day;

	aspect default {
		switch (current_date.day_of_week) {
			match 1 {
				day <- "Monday";
			}

			match 2 {
				day <- "Tuesday";
			}

			match 3 {
				day <- "Wednesday";
			}

			match 4 {
				day <- "Thursday";
			}

			match 5 {
				day <- "Friday";
			}

			match 6 {
				day <- "Saturday";
			}

			match 7 {
				day <- "Sunday";
			}

		}

		draw string(day + string(current_date, " HH:mm:ss")) font: "times" color: #black at: {0, 0.085, 0};
	}

}

//Experiment Setup and Declarations

experiment main type: gui {
	float minimum_cycle_duration <- 0.001;
	output {
		display myView type: 3d {
			species road aspect: base;
			species stop aspect: base;
			species bus aspect: base;
			species clock aspect: default;
		}

	}

}



