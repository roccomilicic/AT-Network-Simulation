model Route_38_MultipleBuses

global {
/* Declare clock attributes */
	float step <- 1 #second;
	date starting_date <- date([2024, 8, 12, 4, 30, 0]);

	/* Import GTFS data for bounds */
	file route_38_bounds <- shape_file("../includes/Route_38_Stops.shp");
	file route_38_stops_csv <- csv_file("../includes/stops.csv", ",");
	file route_38_road_csv <- csv_file("../includes/gtfs_Route_38.csv", ",");
	file multiple_route_38_trips <- csv_file("../includes/stop_times_multiple_Route38.csv");

	/* Declare the graph and shape bounds */
	graph the_graph;
	geometry shape <- envelope(route_38_bounds);

	/* Convert GTFS data into matrices */
	matrix route_38_roads <- matrix(route_38_road_csv);
	matrix route_38_roads_reversed <- reverse(route_38_roads);
	matrix route_38_stops <- matrix(route_38_stops_csv);
	matrix route_38_trips <- matrix(multiple_route_38_trips);

	/* Create variables for keeping count of bus schedule */
	list<string> bus_start_times <- []; // The starting departure time for each bus trip
	list<int> bus_start_times_sequence <- []; // The sequence number of each bus trip
	int next_bus_index <- 0;

	init {
		create clock {
			current_date <- starting_date;
		}

		create stop from: csv_file("../includes/stops.csv", true) with: [stop_name::string(get("stop_name")), lon::float(get("stop_lon")), lat::float(get("stop_lat"))];

		/* Create road points  */
		loop row from: 1 to: route_38_roads.rows - 2 {
		// Declare longitude and latitude of current road point and the next road point
			float lon1 <- route_38_roads[2, row];
			float lat1 <- route_38_roads[1, row];
			float lon2 <- route_38_roads[2, row + 1];
			float lat2 <- route_38_roads[1, row + 1];
			create road {
				lon <- lon1;
				lat <- lat1;
				coordinate <- point({lon, lat});
				location <- point(to_GAMA_CRS(coordinate)); // Convert coordinate to a GAMA location
				lon_next <- lon2;
				lat_next <- lat2;
				point next_coordinate <- point({lon_next, lat_next});
				point next_location <- point(to_GAMA_CRS(next_coordinate)); // Convert coordinate to a GAMA location
				next_road_link <- line(next_location, next_location); // Create a link between current and road points
			}

		}

		the_graph <- directed(as_edge_graph(road)); // Create a graph network of all road points for buses to travel along

		/* Find all trips and save start time to bus_start_times matrix */
		loop i from: 0 to: route_38_trips.rows - 1 {
			if (route_38_trips[11, i] = "True") { // If the bus is leaving the first stop
				add route_38_trips[2, i] to: bus_start_times; // Save bus time to matrix
				add i to: bus_start_times_sequence; // Save the sequence of this bus on the schedule
			}

		}

	}

	/* Check if a bus is ready to depart from this first stop */
	reflex check_bus_departure {
		if (next_bus_index < length(bus_start_times)) { // Check that the next bus is within bounds
			string current_time <- string(current_date, "HH:mm:ss");
			string next_start_time <- bus_start_times at next_bus_index;
			if (current_time = next_start_time) { // If the next bus is ready to depart, create the bus
				do create_bus;
			}

		} else { // Bus scheule is finished
			stop check_bus_departure;
		}

	}

	/* Create a bus once it is ready to depart from the first stop */
	action create_bus {
		if (next_bus_index < length(bus_start_times)) { // Check that the next bus is within bounds
			loop i from: 0 to: 1 { // Create 2 buses, 1 in each direction 
			// In this case, 0 = bus moves up, 1 = bus moves down
				create bus {
					if (i = 0) { // Set start location for one side of the route
						float starting_lon <- route_38_roads[2, 1];
						float starting_lat <- route_38_roads[1, 1];
						coordinate <- point({starting_lon, starting_lat});
						location <- point(to_GAMA_CRS(coordinate));
					} else { // Set start location for other side of the route (bus moves in reverse)
						float starting_lon <- route_38_roads_reversed[route_38_roads.rows - 1, 2];
						float starting_lat <- route_38_roads_reversed[route_38_roads.rows - 1, 1];
						coordinate <- point({starting_lon, starting_lat});
						location <- point(to_GAMA_CRS(coordinate));
					}

					// Create empy lists for departure/arrival times and the bus speeds between stops
					stop_departure_times <- [];
					stop_arrival_times <- [];
					bus_speeds <- [];
					int start_index <- bus_start_times_sequence[next_bus_index]; // Set start index to next bus (allows for quicker searching of GTFS data)
					loop x from: start_index to: route_38_trips.rows - 1 {

					// Set the bus path based on depart/arrival times and bus speeds
						if (i = 0) { // Bus movement for one direction in the route (up)
							add route_38_trips[2, x] to: stop_departure_times;
							add route_38_trips[1, x] to: stop_arrival_times;
							add route_38_trips[10, x] to: bus_speeds;
							bus_path <- list(the_graph) as_path the_graph;
							bus_color <- #blue;
						} else { // Bus movement for other direction in the route (down)
							add route_38_trips[2, x] to: stop_departure_times;
							add route_38_trips[1, x] to: stop_arrival_times;
							add route_38_trips[10, x] to: bus_speeds;
							bus_path <- reverse(list(the_graph)) as_path the_graph;
							bus_color <- #green;
						}

						if (route_38_trips[12, x] = "True") { // Break when end_stop is True
							break;
						}
					}

					write "\nTrip started for Bus ID: " + self + " at " + string(current_date, "HH:mm:ss");
				}

			}

			next_bus_index <- next_bus_index + 1;
		}

	}

}

/* Create stops within the bus route */
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

/* Create road points within the bus route */
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

/* Create buses to move along the route */
species bus skills: [moving] {
	path bus_path;
	point coordinate;
	int bus_stop <- 0;
	list<string> stop_departure_times;
	list<string> stop_arrival_times;
	list<float> bus_speeds;
	float speed_to_next_stop;
	rgb bus_color;

	// Reflex calls my follow every step of the simulation
	reflex myfollow {
		if (bus_stop < length(bus_speeds) and bus_stop < length(stop_departure_times)) { // Check that bus stop is in bounds
			speed_to_next_stop <- (bus_speeds at bus_stop) * 310; // Calculate the speed of the bus based on current pass stop
			if (string(current_date, "HH:mm:ss") >= (stop_departure_times at bus_stop)) { // When the bus should be at the next bus stop, increment bus stop var
				bus_stop <- bus_stop + 1;
				if (bus_stop >= length(stop_arrival_times)) { // When bus stop reaches last stop, die
					write "\nTrip ended for Bus ID: " + self + " at " + string(current_date, "HH:mm:ss");
					do die;
				}

			}

			do follow speed: speed_to_next_stop path: bus_path;
		}

	}

	aspect base {
		draw rectangle(0.0008, 0.002) color: bus_color border: #black;
		loop seg over: bus_path.edges {
			draw seg color: color;
		}

	}

}

/* Create a clock for the bus schedule to run by */
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
