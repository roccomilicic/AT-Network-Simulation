model Route_38

global {
	file route_38_bounds <- shape_file("../includes/Route_38_Stops.shp");
	file route_38_csv <- csv_file("../includes/stops.csv", ",");
	file route_38_road_csv <- csv_file("../includes/gtfs_Route_38.csv", ",");
	file single_trip_route38_csv <- csv_file("../includes/single_trip_Route38.csv");
	file single_trip_stop_times_route38_csv <- csv_file("../includes/stop_times_single_Route38.csv");
	graph the_graph;
	geometry shape <- envelope(route_38_bounds);

	// Variables for the clock species
	date starting_date <- date([2024, 8, 12, 4, 30, 0]);
	float step <- 1 #second;

	// Route matrixes for CSV data
	matrix data <- matrix(route_38_road_csv);
	matrix route38_data <- matrix(route_38_csv);

	init {
	// Create stops from the CSV file data
		create stop from: csv_file("../includes/stops.csv", true) with: [stop_name::string(get("stop_name")), lon::float(get("stop_lon")), lat::float(get("stop_lat"))];

		// Create roads of the bus route from the CSV file data
		loop row from: 1 to: data.rows - 2 { // Iterate through rows, stopping at the second to last row
			write "\nProcessing row: " + row;
			float lon1 <- data[2, row]; // Longitude for the current row
			float lat1 <- data[1, row]; // Latitude for the current row
			float lon2 <- data[2, row + 1]; // Longitude for the next row
			float lat2 <- data[1, row + 1]; // Latitude for the next row


			// Create road species based on collected data from CSV
			create road {
			// Lon and lat values for current point 
				lon <- lon1;
				lat <- lat1;

				// Lon and lat values for next point
				lon_next <- lon2;
				lat_next <- lat2;

				// Location for the current point to put the beginning of the road on the map
				coordinate <- point({lon, lat});
				location <- point(to_GAMA_CRS(coordinate));

				// Location for the next stop to put the beginning of the road on the map
				point next_stop_coordinate <- point({lon_next, lat_next});
				point next_stop_location <- point(to_GAMA_CRS(next_stop_coordinate));

				// Link the 2 stops together
				next_stop_link <- line(location, next_stop_location);
			}

		}

		the_graph <- as_edge_graph(road);
		matrix trip_data <- matrix(single_trip_route38_csv);
		matrix stop_times_data <- matrix(single_trip_stop_times_route38_csv);
		create bus {
			float starting_lon <- data[2, 1];
			float starting_lat <- data[1, 1]; // Latitude for the current row
			coordinate <- point({starting_lon, starting_lat});
			location <- point(to_GAMA_CRS(coordinate));
			trip_id <- trip_data[2, 0];
			loop x from: 0 to: stop_times_data.rows - 1 {
				add stop_times_data[2, x] to: stop_departure_times;
				add stop_times_data[1, x] to: stop_arrival_times;
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

	reflex myfollow {
		// Loop through each stop time
		
		loop x from: 0 to: length(stop_arrival_times) - 1 {
			string current_arrival_time <- stop_arrival_times at x;
			string current_departure_time <- stop_departure_times at x;

			// Check if the current time matches the stop's arrival time
			if string(current_date, " HH:mm:ss") = " " + current_arrival_time {
				write "\nArriving at stop: " + x + " @ " + current_arrival_time;
				// Move the bus to the next stop
				do follow path: path_following speed: 3.0;

				// Wait until the departure time before moving to the next stop
				if string(current_date, " HH:mm:ss") = " " + current_departure_time {
					write "Departing from stop: " + x + "\n------------------------\n";
					// Move to the next stop after the departure time
					//do move distance: 0.001 on: path_following;
					do follow path: path_following speed: 3.0;
					break;
				}

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