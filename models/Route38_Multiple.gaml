model Route_38

global {
	file route_38_bounds <- shape_file("../includes/Route_38_Stops.shp");
	file route_38_stops_csv <- csv_file("../includes/stops.csv", ",");
	file route_38_road_csv <- csv_file("../includes/gtfs_Route_38.csv", ",");
	file all_bus_trips <- csv_file("../includes/single_trip_Route38.csv");
	file route_38_trip <- csv_file("../includes/stop_times_single_Route38.csv");
	file multiple_route_38_trips <- csv_file("../includes/stop_times_multiple_Route38.csv");
	graph the_graph;
	graph the_graph_reversed;
	geometry shape <- envelope(route_38_bounds);

	// Variables for the clock species
	date starting_date <- date([2024, 8, 12, 4, 42, 0]);
	float step <- 1 #second;

	// Route matrixes for CSV route_38_roads
	matrix route_38_roads <- matrix(route_38_road_csv);
	matrix route_38_roads_reversed <- reverse(route_38_roads);
	matrix route_38_stops <- matrix(route_38_stops_csv);

	// Bus routes
	matrix all_bus_trips_matrix <- matrix(all_bus_trips);
	matrix route_38_trip_matrix <- matrix(route_38_trip);
	matrix route_38_multiple_trip_matrix <- matrix(multiple_route_38_trips);
	string first_departure_time <- route_38_trip_matrix[2, 0];
	list<string> bus_start_times <- [];
	int next_bus_index <- 0; // Index to keep track of the next bus to create
	list<int> bus_start_times_index <- [];

	init {
		create clock {
			current_date <- starting_date;
		}

		create stop from: csv_file("../includes/stops.csv", true) with: [stop_name::string(get("stop_name")), lon::float(get("stop_lon")), lat::float(get("stop_lat"))];

		// Create roads of the bus route from the CSV file route_38_roads
		loop row from: 1 to: route_38_roads.rows - 2 { // Iterate through rows, stopping at the second to last row
			write "\nProcessing row: " + row;
			float lon1 <- route_38_roads[2, row]; // Longitude for the current row
			float lat1 <- route_38_roads[1, row]; // Latitude for the current row
			float lon2 <- route_38_roads[2, row + 1]; // Longitude for the next row
			float lat2 <- route_38_roads[1, row + 1]; // Latitude for the next row


			// Create road species based on collected route_38_roads from CSV
			create road {
			// Lon and lat values for current point 
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

				// Link the 2 stops together
				next_road_link <- line(next_location, next_location);
			}

		}

		the_graph <- directed(as_edge_graph(road)); // Create graph for all road points

		// Populate bus_start_times with start times from the matrix (where the first stop is true)
		loop i from: 0 to: route_38_multiple_trip_matrix.rows - 1 {
			if (route_38_multiple_trip_matrix[11, i] = "True") {
				add route_38_multiple_trip_matrix[2, i] to: bus_start_times;
				add i to: bus_start_times_index;
			}

		}

		the_graph_reversed <- reverse(the_graph);
	}

	reflex check_bus_departure {
	// Check if the current time matches the next bus's start time
		if (next_bus_index < length(bus_start_times)) { // Ensure we don't go out of bounds
			string current_time <- string(current_date, "HH:mm:ss");
			string next_start_time <- bus_start_times at next_bus_index;

			// Only proceed to create a bus if the current time matches the next bus's start time
			if (current_time = next_start_time) {
			// Call the bus creation function when the time matches
				do create_bus;
			}

		} else {
		// Stop this reflex if all buses are created
			stop check_bus_departure;
		}

	}
	
	

	action create_bus {
	// Ensure the next bus index is within the start times array
		if (next_bus_index < length(bus_start_times)) {
		// Create the bus object and initialize its data
			loop i from: 0 to: 1 {
			// In this case int 0 represents the bus moving one direction, and int 1 in the other direction
				create bus {
				// Initialize the bus with its starting coordinates and stop details
					if (i = 0) {
						float starting_lon <- route_38_roads[2, 1];
						float starting_lat <- route_38_roads[1, 1];
						write "start lon: " +  starting_lon;
						coordinate <- point({starting_lon, starting_lat});
						location <- point(to_GAMA_CRS(coordinate));
					} else {
						float starting_lon <- route_38_roads_reversed[route_38_roads.rows -1 , 2];
						float starting_lat <- route_38_roads_reversed[route_38_roads.rows -1, 1];
						write "start rev lon: " +  starting_lon;
						coordinate <- point({starting_lon, starting_lat});
						location <- point(to_GAMA_CRS(coordinate));
						write "point: " + route_38_roads_reversed[0, 3];
					}

					trip_id <- all_bus_trips_matrix[2, 0];

					// Initialize the bus's stop-related data uniquely for each bus
					bus_stop <- 0;
					stop_departure_times <- [];
					stop_arrival_times <- [];
					bus_speeds <- [];
					int start_index <- bus_start_times_index[next_bus_index];

					// Fill the bus-specific stop and speed data
					loop x from: start_index to: route_38_multiple_trip_matrix.rows - 1 {
						if (route_38_multiple_trip_matrix[12, x] = "True") {
							break;
						} else {
							if (i = 0) {
								add route_38_multiple_trip_matrix[2, x] to: stop_departure_times;
								add route_38_multiple_trip_matrix[1, x] to: stop_arrival_times;
								add route_38_multiple_trip_matrix[10, x] to: bus_speeds;
								reversed <- false;
								bus_path <- list(the_graph) as_path the_graph;
								bus_color <- #blue;
								//bus_path <- list(the_graph) as_path the_graph;
								//write "\nBus ID: " + self + " is noromal.";
								//write "\nBus ID: " + self + " reversed";
							} else {
							//								add reverse(route_38_multiple_trip_matrix[2, x]) to: stop_departure_times;
							//								add reverse(route_38_multiple_trip_matrix[1, x]) to: stop_arrival_times;
							//								add reverse(route_38_multiple_trip_matrix[10, x]) to: bus_speeds;
								add route_38_multiple_trip_matrix[2, x] to: stop_departure_times;
								add route_38_multiple_trip_matrix[1, x] to: stop_arrival_times;
								add route_38_multiple_trip_matrix[10, x] to: bus_speeds;
								
								bus_path <- reverse(list(the_graph)) as_path the_graph;
								reversed <- true;
								bus_color <- #green;
								//write "\nBus ID: " + self + " is reversed.";
								//write "\nBus ID: " + self + " reversed";
								//bus_path <- reverse(list(the_graph)) as_path the_graph;
							}

						}

					}

				}

			}

			// Move to the next bus in the list
			next_bus_index <- next_bus_index + 1;
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
	//path bus_path <- list(the_graph) as_path the_graph;
	path bus_path;
	path path_following;
	string trip_id;
	list<string> stop_departure_times;
	list<string> stop_arrival_times;
	list<float> bus_speeds;
	int bus_stop <- 0;
	float speed_to_next_stop;
	bool has_reached_end <- false;
	bool reversed;
	rgb bus_color;

	reflex myfollow {
	// Determine the path based on the reversed state
	//write "\nBus ID: " + self + " is running.";


	// Check if the bus has more stops to go to
		if (bus_stop < length(bus_speeds) and bus_stop < length(stop_departure_times)) {
			speed_to_next_stop <- (bus_speeds at bus_stop) * 310;

			// Check if the current time matches or exceeds the departure time
			if (string(current_date, "HH:mm:ss") >= (stop_departure_times at bus_stop)) {
				bus_stop <- bus_stop + 1;
				if (bus_stop >= length(bus_speeds)) {
				// This bus has reached the last stop
					write "\nBus ID: " + self + " has reached the last stop and will be deleted.";
					do die;
				}

			}

			// Continue following the path with the calculated speed
			do follow speed: speed_to_next_stop path: bus_path;
		}

	}

	aspect base {
		draw rectangle(0.0008, 0.002) color: bus_color border: #black; // Draw the bus
		loop seg over: bus_path.edges {
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