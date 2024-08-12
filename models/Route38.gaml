/**
* Name: Route_38
* Route 38 example 
* Author: jonat
* Tags: 
*/

// did a thing

model Route_38

global {
	file route_38_bounds <- shape_file("../includes/Route_38_Stops.shp");
	file route_38_csv <- csv_file("../includes/stops.csv", ",");
	graph the_graph;
	geometry shape <- envelope(route_38_bounds);

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
			

		}
		the_graph <- as_edge_graph(road);
		loop row from: 1 to: 1 {
			create bus {
				float starting_lon <- data[5, row];
				float starting_lat <- data[4, row]; // Latitude for the current row
				coordinate <- point({starting_lon, starting_lat});
				location <- point(to_GAMA_CRS(coordinate));
			}

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
	

	reflex myfollow{
		do follow path: path_following;
	}

	aspect base {
		draw rectangle(0.001, 0.004) color: #blue border: #black; // Draw the bus
		loop seg over: path_following.edges {
	  		draw seg color: color;
	 	 }
	}

}

experiment main type: gui {
	float minimum_cycle_duration <- 2;
	output {
		display myView{
			species road aspect: base;
			species stop aspect: base;
			species bus aspect: base;
		}
	}
}
	