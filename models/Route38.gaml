model Route_38

global {
	file route_38_bounds <- shape_file("../includes/Route_38_Stops.shp");
	file route_38_stops_csv <- csv_file("../includes/stops38_35.csv", ",");
	file route_38_road_csv <- csv_file("../includes/gtfs_route_38_35.csv", ",");
	file all_bus_trips <- csv_file("../includes/single_trip_Route38.csv");
	file route_38_trip <- csv_file("../includes/stop_times_single_Route38.csv");
	file multiple_route_38_trips <- csv_file("../includes/stop_times_multiple_Route38.csv");
	graph the_graph;
	graph graph_route38;
	graph graph_route35;
	geometry shape <- envelope(route_38_bounds);

	// Variables for the clock species
	date starting_date <- date([2024, 8, 12, 4, 42, 0]);
	float step <- 1 #second;

	// Route matrixes for CSV route_38_roads
	matrix route_38_roads <- matrix(route_38_road_csv);
	matrix route_38_stops <- matrix(route_38_stops_csv);

	// Bus routes
	matrix all_bus_trips_matrix <- matrix(all_bus_trips);
	matrix route_38_trip_matrix <- matrix(route_38_trip);
	matrix route_38_multiple_trip_matrix <- matrix(multiple_route_38_trips);
	string first_departure_time <- route_38_trip_matrix[2, 0];
	list<string> bus_start_times <- [];
	int next_bus_index <- 0; // Index to keep track of the next bus to create
	init {
		create clock {
			current_date <- starting_date;
		}

		create stop from: csv_file("../includes/stops38_35.csv", true) with: [stop_name::string(get("stop_name")), lon::float(get("stop_lon")), lat::float(get("stop_lat"))];

		// Create roads of the bus route from the CSV file route_38_roads
		loop row from: 1 to: route_38_roads.rows - 2 { // Iterate through rows, stopping at the second to last row
		//write "\nProcessing row: " + row;
			float lon1 <- route_38_roads[2, row]; // Longitude for the current row
			float lat1 <- route_38_roads[1, row]; // Latitude for the current row
			float lon2 <- route_38_roads[2, row + 1]; // Longitude for the next row
			float lat2 <- route_38_roads[1, row + 1]; // Latitude for the next row

			string shape_id <- route_38_roads[0, row];
			string shape_id_next <- route_38_roads[0, row + 1];

			// Create road species based on collected route_38_roads from CSV
			create road {
			// Lon and lat values for current point 
				
				if (shape_id = shape_id_next) {
					
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

		the_graph <- as_edge_graph(road); // Create graph for all road points

		// Populate bus_start_times with start times from the matrix (where the first stop is true)
		loop i from: 0 to: route_38_multiple_trip_matrix.rows - 1 {
			if (route_38_multiple_trip_matrix[11, i] = "True") {
				add route_38_multiple_trip_matrix[2, i] to: bus_start_times;
			}

		}

	}

	reflex check_bus_creation {
		if (next_bus_index < length(bus_start_times)) { // Ensure we don't go out of bounds
			string current_time <- string(current_date, "HH:mm:ss");
			string next_start_time <- bus_start_times at next_bus_index;
			//write "Next start time: " + next_start_time;
			if (current_time >= next_start_time) {
				create bus {
					float starting_lon <- route_38_roads[2, 1];
					float starting_lat <- route_38_roads[1, 1];
					coordinate <- point({starting_lon, starting_lat});
					location <- point(to_GAMA_CRS(coordinate));
					trip_id <- all_bus_trips_matrix[2, 0]; // Get the trip ID of bus agent
					loop x from: 0 to: route_38_trip_matrix.rows - 1 {
						add route_38_trip_matrix[2, x] to: stop_departure_times;
						add route_38_trip_matrix[1, x] to: stop_arrival_times;
						add route_38_trip_matrix[10, x] to: bus_speeds;
					}

				}

				// Move to the next bus in the list
				next_bus_index <- next_bus_index + 1;
			}

		} else {
			stop check_bus_creation; // Stop checking when all buses are created
		}

	}

}

species stop {
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
	int count;

	reflex myfollow {
		int bus_stop <- 0;
		loop i from: 0 to: length(route_38_stops) - 1 { // Each route point within the route (makes up the road)
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