model AucklandBusNetwork

global {
    file shape_file_routes <- file("../includes/BusRoutes/BusService.shp");
    file shape_file_bounds <- file("../includes/AucklandBounds/Auckland_Bounds.shp");
    file shape_file_stops <- file("../includes/BusStops/BusService.shp");
    
    geometry shape <- envelope(shape_file_bounds);
    
    graph the_graph;
    
    //number of buses
    int nb_buses <- 50;
    
    float step <- 1 #seconds;
    
    init {
        create routes from: shape_file_routes;
        create stops from: shape_file_stops;
        
        the_graph <- as_edge_graph(stops);
        
        create bus number: nb_buses {
            location <- any_location_in(one_of(stops));
        }
        
    }
}

species routes {
    rgb color <- #black;
    
    aspect base {
        draw shape color: color;
    }
}

species stops {
    rgb color <- #green;
    
    aspect base {
        draw circle(100) color: color;
    }
}

species bus skills: [moving] {

    float speed <- 120 #km / #h;
    rgb color <- #blue;
    path path_following <- list(the_graph) as_path the_graph;
    
	reflex myfollow {
		do follow path: path_following speed: speed;
	}
    
    aspect base {
        draw rectangle(300, 600) color: color;
    }
}

experiment AucklandBusSimulation type: gui {
    parameter "Number of buses" var: nb_buses min: 10 max: 200 category: "Buses";
    
    output {
        display main_display type: 3d {
            species routes aspect: base;
            species stops aspect: base;
            species bus aspect: base;
        
        }
    }
}