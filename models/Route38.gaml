model Route_38

global {
// Import files
	file route_38_bounds <- shape_file("../includes/Route_38_Stops.shp");
	file route_38_stops <- csv_file("../includes/stops.csv", ",");
	file route_38_roads <- csv_file("../includes/gtfs_Route_38.csv", ",");
	file route_38_trip <- csv_file("../includes/stop_times_single_Route38.csv");
	file all_bus_trips <- csv_file("../includes/single_trip_Route38.csv"); // List of all bus trips
	graph the_graph; // Create graph (for the road points)
	geometry shape <- envelope(route_38_bounds); // Create a bounds for the route

	// Variables for clock species
	date starting_date <- date([2024, 8, 12, 4, 42, 0]);
	float step <- 1 #second;

	// Route matrixes for CSV data
	matrix data <- matrix(route_38_roads);
	matrix route38_data <- matrix(route_38_stops);

	init {
	// Create stops from the CSV file data
		create stop from: csv_file("../includes/stops.csv", true) with: [stop_name::string(get("stop_name")), lon::float(get("stop_lon")), lat::float(get("stop_lat"))];

		// Create the roads points for the bus route from the CSV data
		loop row from: 1 to: data.rows - 2 {
			write "\nProcessing row: " + row;
			float lon1 <- data[2, row]; // Longitude for the current row
			float lat1 <- data[1, row]; // Latitude for the current row
			float lon2 <- data[2, row + 1]; // Longitude for the next row
			float lat2 <- data[1, row + 1]; // Latitude for the next row
			create road {
			// Lon and lat values for current road point 
				lon <- lon1;
				lat <- lat1;

				// Location for the current road point
				coordinate <- point({lon, lat});
				location <- point(to_GAMA_CRS(coordinate));

				// Lon and lat values for next road point
				lon_next <- lon2;
				lat_next <- lat2;

				// Location for the next road point 
				point next_coordinate <- point({lon_next, lat_next});
				point next_location <- point(to_GAMA_CRS(next_coordinate));

				// Link the 2 road points together
				next_stop_link <- line(location, next_location);
			}

		}

		the_graph <- as_edge_graph(road);
		matrix all_trips <- matrix(all_bus_trips); // Matrix of all bus trips
		matrix route38_trip <- matrix(route_38_trip); // Matrix of route 38 bus trip details
		create bus {
		// Set location of bus species to the first stop
			float lon_start <- data[2, 1];
			float lat_start <- data[1, 1]; // Latitude for the current row
			coordinate <- point({lon_start, lon_start});
			location <- point(to_GAMA_CRS(coordinate));
			trip_id <- all_trips[2, 0]; // Trip ID of bus agent
			loop x from: 0 to: route38_trip.rows - 1 {
				add route38_trip[2, x] to: stop_departure_times;
				add route38_trip[1, x] to: stop_arrival_times;
				add route38_trip[10, x] to: bus_speeds;
			}

		}

		create clock {
			current_date <- starting_date;
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
	geometry next_stop_link;

	aspect base {
		draw shape color: #red;
		draw next_stop_link color: #pink;
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
		loop i from: 0 to: length(route38_data) - 1 { // Each route point within the route (makes up the road)
			write "\nCURRENT STOP: " + bus_stop;
			float speed_to_next_stop <- bus_speeds at bus_stop; // Save speed of bus depending on arrival stop
			if string(current_date, " HH:mm:ss") >= " " + stop_departure_times at bus_stop { // If clock passes bus stop time
				bus_stop <- bus_stop + 1; // Incremenet bus stop number
				write "\nLooping stop: " + bus_stop + " @ " + stop_departure_times at bus_stop;
				write "Current speed for this segment: " + speed_to_next_stop + " m/s";
				do follow path: path_following speed: speed_to_next_stop; // follow the path with given speed for current bus stop
			}

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