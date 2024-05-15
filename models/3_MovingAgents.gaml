/**
* Name: NewModel1
* Based on the internal empty template. 
* Author: jessi
* Tags: 
*/

/* Insert your model definition here */

/**
* Name: Loading of GIS data (buildings and roads)
* Author: Jessica
* Description: first part of the tutorial: Road Traffic
* Tags: gis
*/

model NewModel8

global {
        file shape_file_routes <- file("../includes/BusRoutes/BusService.shp");
        file shape_file_bounds <- file("../includes/AucklandBounds/Auckland_Bounds.shp");
        file shape_file_stops <- file("../includes/BusStops/BusService.shp");
        file csv_stop_times <- csv_file("../includes/stop_times_trimmed.csv", ",");
        matrix stop_times_matrix <- matrix(csv_stop_times);
        
		list<string> stop_times_trip_id <- stop_times_matrix column_at(0);
		list<string> stop_times_arrival_time <- stop_times_matrix column_at(1);
		list<string> stop_times_departure_time <- stop_times_matrix column_at(2);
		list<string> stop_times_stop_id <- stop_times_matrix column_at(3);
		list<string> stop_times_stop_sequence <- stop_times_matrix column_at(4);
		list<string> stop_times_stop_headsign <- stop_times_matrix column_at(5);
		list<string> stop_times_pickup_type <- stop_times_matrix column_at(6);
		list<string> stop_times_drop_off_type <- stop_times_matrix column_at(7);
		list<string> stop_times_shape_dist_traveled <- stop_times_matrix column_at(8);
		list<string> stop_times_timepoint <- stop_times_matrix column_at(9);
        
        geometry shape <- envelope(shape_file_bounds);
        float step <- 10 #mn;
        
        int nb_people<- 100;
        graph the_graph;
    
        init {
        	
        	write "\n"+stop_times_trip_id;
    		write "\n"+stop_times_stop_id;
    		write "\n"+stop_times_stop_sequence;
    		write "\n"+stop_times_stop_headsign;
        	
            create routes from: shape_file_routes ;
            create stops from: shape_file_stops ;
            the_graph <- as_edge_graph(routes);
            // Create people agents similar to second model
        	create people number:nb_people {
            	location <- any_location_in(one_of(stops));
            	speed <- rnd(1.0 #km/#h, 5.0 #km/#h); // Random speed between 1.0 and 5.0 km/h
            	start_work <- rnd(6, 8); // Random start work hour between 6 and 8 AM
            	end_work <- rnd(16, 20); // Random end work hour between 4 and 8 PM
            	working_place <- one_of(stops);
            	living_place <- one_of(stops);
            	objective <- "resting";
        	}
        }
}

species routes {
    string type; 
    rgb color <- #black  ;
    
    aspect base {
    draw shape color: color ;
    }
}

species stops {
	string type; 
	rgb color <- #green  ;
	
	aspect base {
		draw shape color: color ;
	}
}

species people skills:[moving] {
    rgb color <- #red;
    int start_work;
    int end_work;
    stops working_place;
    stops living_place;
    string objective;
    point the_target <- nil;
    
    reflex time_to_work when: current_date.hour = start_work {
        objective <- "working";
        the_target <- any_location_in (working_place);
    }
    
    reflex time_to_go_home when: current_date.hour = end_work and objective = "working" {
        objective <- "resting";
        the_target <- any_location_in (living_place);
    }
    
    reflex move when: the_target != nil {
        do goto target: the_target on: the_graph;
        
        if the_target = location {
            the_target <- nil;
        }
    }
    
    
    }

experiment AT type: gui {
    parameter "Shapefile for the routes:" var: shape_file_routes category: "GIS" ;
    
    output {
        display akl_city type:3d {
            species routes aspect: base ;
            species stops aspect: base ;
            species people ;
        }
        display chart_display refresh: every(10#cycles) type: 2d {
            chart "People Objectives" type: pie {
                data "working" value: people count(each.objective="working") color: #magenta;
                data "resting" value: people count(each.objective="resting") color: #blue;
            }
        }
    }
}