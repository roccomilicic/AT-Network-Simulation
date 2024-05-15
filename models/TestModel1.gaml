/**
* Name: NewModel1
* Based on the internal empty template. 
* Author: jessi
* Tags: 
*/

/* Insert your model definition here */

/**
* Name: Loading of GIS data (buildings and roads)
* Author: Jessi
* Description: first part of the tutorial: Road Traffic
* Tags: gis
*/

model NewModel1

global {
        file shape_file_routes <- file("../includes/BusRoutes/BusService.shp");
        file shape_file_bounds <- file("../includes/AucklandBounds/Auckland_Bounds.shp");
        file shape_file_stops <- file("../includes/BusStops/BusService.shp");
        
        geometry shape <- envelope(shape_file_bounds);
        float step <- 10 #mn;
        
        int nb_people<- 100;
        graph the_graph;
    
        init {
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
    }
}