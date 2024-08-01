/**
* Name: Movement of an agent on different paths
* Author: 
* Description: Model showing the movement of an agent following three different paths : one defined by its vertices, another defined thanks to all the roads species, and finally 
*       a path defined by a graph with weights (graph created thanks to another species)
* Tags: graph, agent_movement, skill
*/
model NewModelone3

global {
    graph the_graph;
    int nb_stops <- 23;
   // geometry bounds <- envelope({-100, -100}, {1000, 1000}); // Define the bounds for the display
    
    init {
        // Define roads with their shapes
        create road {
            shape <- line([{0, 0}, {0, -10}, {0, -20}, {0, -30}, {0, -40}]);
        }
        create road {
            shape <- line([{0, -40}, {10, -40}, {20, -40}, {30, -40}]);
        }
        create road {
            shape <- line([{30, -40}, {30, 0}, {30, 30}, {30, 60}, {30, 90}, {30, 120}, {30, 150}, {30, 180}]);
        }
        create road {
            shape <- line([{30, 180}, {60, 180}, {90, 180}, {120, 180}, {130, 190}, {130, 245}]);
        }
        create road {
            shape <- line([{130, 245}, {100, 250}, {70, 250}, {30, 250}]);
        }
        create road {
            shape <- line([{30, 250}, {30, 280}, {30, 340}, {30, 380}, {30, 410}]);
        }
        create road {
            shape <- line([{30, 410}, {20, 415}, {10, 418}, {10, 420}, {10, 450}, {-10, 460}, {-40, 470}, {-70, 480}]);
        }
        
        // Create graph from roads
        the_graph <- as_edge_graph(road);
        
        // Define specific coordinates for the bus stops along the roads
        list<point> stop_locations <- [
            {0, 0}, {30, 30}, {30, 55}, {30, 90}, {30, 120}, {30, 150},
            {60, 180}, {90, 180}, {120, 180}, {130, 190}, {120, 247}, 
            {100, 250}, {70, 250}, {30, 255}, 
            {30, 275}, {30, 340}, {30, 370}, {30, 400},
            {27, 411}, {14, 417}, {7, 452}, {-10, 460}, {-70, 480}
        ];
        
        // Create bus stop nodes at specified locations
        loop i from: 0 to: nb_stops - 1 {
            create stop {
                location <- stop_locations[i];
            }
        }
        
        // Create bus agent
        create bus {
            location <- {0, 0};
        }
    }
}

species stop {
    aspect base {
        draw circle(1) color: #green;
    }
}

species bus skills: [moving] {
    path path_to_follow1 <- path([
        {0, 0}, {0, -10}, {0, -20}, {0, -30}, {0, -40}, 
        {10, -40}, {20, -40}, {30, -40}, 
        {30, 0}, {30, 30}, {30, 60}, {30, 90}, {30, 120}, {30, 150}, {30, 180},
        {60, 180}, {90, 180}, {120, 180}, {130, 190}, {130, 240}, 
        {100, 250}, {70, 250}, {30, 250}, 
        {30, 280}, {30, 340}, {30, 380}, {30, 410}
    ]);	
    path path_following <- path_to_follow1;
    rgb color <- #green;
    
    reflex myfollow {
        // Move along the path
        do follow path: path_following;	
    }
    
    aspect base {
        draw circle(1) color: #yellow; // Draw the bus
        // Draw the path the bus is following
        loop seg over: path_following.edges {
            draw seg color: color;
        }
    } 

    
    aspect base {
        draw circle(1) color: #yellow; // Draw the bus
    } 
}

species road {
    aspect base {
        draw shape color: #red;
    } 
}

experiment main type: gui {
    float minimum_cycle_duration <- 0.10;
    output {
        display myView type: 3d {
            species road aspect: base;
            species stop aspect: base;
            species bus aspect: base;
        //    geometry bounds; // Add bounds to the display
        }
    }
}