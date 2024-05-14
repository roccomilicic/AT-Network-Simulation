/**
* Name: NewModel1
* Based on the internal empty template. 
* Author: jessi
* Tags: test
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
    
        init {
            create routes from: shape_file_routes ;
            create stops from: shape_file_stops ;
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

experiment AT type: gui {
    parameter "Shapefile for the routes:" var: shape_file_routes category: "GIS" ;
    
    output {
        display akl_city type:3d {
            species routes aspect: base ;
            species stops aspect: base ;
        }
    }
}