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

model NewModel4

global {
        file shape_file_routes <- file("../includes/BusRoutes/BusService.shp");
        file shape_file_bounds <- file("../includes/AucklandBounds/Auckland_Bounds.shp");
        file shape_file_stops <- file("../includes/BusStops/BusService.shp");
        
        geometry shape <- envelope(shape_file_bounds);
        float step <- 10 #mn;
        
        int nb_people<- 100;
    
        init {
            create routes from: shape_file_routes ;
            create stops from: shape_file_stops ;
            // Create people agents similar to second model
        	create people number:nb_people {
            	location <- any_location_in(one_of(stops));
            	speed <- rnd(1.0 #km/#h, 5.0 #km/#h); // Random speed between 1.0 and 5.0 km/h
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
    
    }

experiment AT type: gui {
    parameter "Shapefile for the routes:" var: shape_file_routes category: "GIS" ;
    
    output {
        display akl_city type:3d {
            species routes aspect: base ;
            species stops aspect: base ;
            species people;
        }
    }
}