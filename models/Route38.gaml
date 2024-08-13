/**
* Name: Route_38
* Route 38 example 
* Author: jonat
* Tags: 
*/
model Route_38

global {
	file route_38_bounds <- shape_file("../includes/Route_38_Stops.shp");
	file route_38_csv <- csv_file("../includes/stops.csv", ",");
	graph the_graph;
	geometry shape <- envelope(route_38_bounds);
<<<<<<< Updated upstream
=======
	
	// Variables for the clock
	date starting_date <- date([2024, 8, 12, 0, 0, 0]);
	int zoom <- 4 min:2 max:10;
	float step <- 1#second; 
>>>>>>> Stashed changes

	init {
	// Create stops from the CSV file data
		create stop from: csv_file("../includes/stops.csv", true) with: [stop_name::string(get("stop_name")), lon::float(get("stop_lon")), lat::float(get("stop_lat"))];

		// Create roads of the bus route from the CSV file data
		matrix data <- matrix(route_38_csv);
		loop row from: 1 to: data.rows - 2 { // Iterate through rows, stopping at the second to last row
			write "\nProcessing row: " + row;
			float lon1 <- data[5, row]; // Longitude for the current row
			float lat1 <- data[4, row]; // Latitude for the current row
			float lon2 <- data[5, row + 1]; // Longitude for the next row
			float lat2 <- data[4, row + 1]; // Latitude for the next row

			// Create road species based on collect data from CSV
			create road {
			// Lon and lat values for current stop 
				lon <- lon1;
				lat <- lat1;

				// Lon and lat values for next stop
				lon_next <- lon2;
				lat_next <- lat2;

				// Location for the current stop to put the begginning of the road on the map
				coordinate <- point({lon, lat});
				location <- point(to_GAMA_CRS(coordinate));

				// Location for the next stop to put the begginning of the road on the map
				point next_stop_coordinate <- point({lon_next, lat_next});
				point next_stop_location <- point(to_GAMA_CRS(next_stop_coordinate));

				// Link the 2 stops together
				next_stop_link <- line(location, next_stop_location);
			}

			// Create the clock species
			create clock {
				current_date <- starting_date;
				
			}

		}

		the_graph <- as_edge_graph(road);
<<<<<<< Updated upstream
		loop row from: 1 to: 1 {
			create bus {
				float starting_lon <- data[5, row];
				float starting_lat <- data[4, row]; // Latitude for the current row
				coordinate <- point({starting_lon, starting_lat});
				location <- point(to_GAMA_CRS(coordinate));
=======
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
>>>>>>> Stashed changes
			}

		}

<<<<<<< Updated upstream
		
=======
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
	

	reflex myfollow{
=======
	string trip_id;
	list<string> stop_departure_times;
	list<string> stop_arrival_times;

	reflex myfollow {
>>>>>>> Stashed changes
		do follow path: path_following;
	}

	aspect base {
		draw rectangle(0.001, 0.004) color: #blue border: #black; // Draw the bus
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
			match 1 {day <- "Monday";}
			match 2 {day <- "Tuesday";}
			match 3 {day <- "Wednesday";}
			match 4 {day <- "Thursday";}
			match 5 {day <- "Friday";}
			match 6 {day <- "Saturday";}
			match 7 {day <- "Sunday";}
		}
		
		draw string(day + string(current_date, " HH:mm:ss")) size: zoom / 1.5 font: "times" color: #black at: {0.001, -0.005, 0.001};
	}

}

experiment main type: gui {
<<<<<<< Updated upstream
	float minimum_cycle_duration <- 2;
=======
	float minimum_cycle_duration <- 0.1;
>>>>>>> Stashed changes
	output {
		display myView type: 3d {
			species road aspect: base;
			species stop aspect: base;
			species bus aspect: base;
			species clock aspect: default;
		}

	}

}
	