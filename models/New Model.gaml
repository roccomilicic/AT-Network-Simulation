/**
* Name: NewModel
* Based on the internal empty template. 
* Author: jessi
*/



/* Insert your model definition here */
/**
* Name: GISdata
* Based on the internal skeleton template. 
* Author: Romaric Sallustre
* Tags: 
*/

model NewModel

global {
	// drag and drop the file from include (loading files)
	shape_file bounds0_shape_file <- shape_file("../includes/bounds.shp");

	shape_file building0_shape_file <- shape_file("../includes/shapes.shp");

	shape_file road0_shape_file <- shape_file("../includes/Transit_Lanes.shp");
	
	float step<- 1#mn; // assigning a timestep of 10 minute intervals
						//  distance covered by the agent in 1 min
						
	geometry shape <- envelope(building0_shape_file); // geometry w.r.to bounds
	
	int nb_people<- 100;
	
	//adding parameter for people agent
	date starting_date <-date("2019-09-01-00-00-00");
	int min_work_start <-6;
	int max_work_start <- 8;
	int min_work_end <-16;
	int max_work_end <- 20;
	float min_speed <- 1.0 #km/#h;
	float max_speed <- 5.0 #km/#h;
	//float avg_speed <- max_speed/min_speed;
	graph the_graph;
	
	init{
		// create building from shape file with type as residential initially and if case for industrial
		create building from: building0_shape_file with:[type:read("NATURE")]{
			if type="Industrial"{
				color<-#yellow;
			}
			depth<-rnd(100);
		}
		
		create road from:road0_shape_file;
		the_graph <- as_edge_graph(road); // initialise the road as graph
		// create buildings which are residential
		list<building> residential_building<-building where (each.type="Residential");
		
		list<building> industrial_building<-building where (each.type="Industrial");
		
		// create people agents in the resi. buildings
		create people number:nb_people{
			location<-any_location_in(one_of(residential_building));
			
			// adding additional parameter in the intiation of people agents
			
			speed <- rnd(min_speed, max_speed);
			start_work <- rnd(min_work_start, max_work_start);
			end_work <- rnd(min_work_end, max_work_end);
			living_place <- one_of(residential_building);
			working_place <- one_of(industrial_building);
			objective <- "resting";
			location <- any_location_in (living_place);
			
		}
		
		
	}

	
}

species building{
	string type; // type of the building (residential, industrial)
	rgb color<-#gray; // building color
	int depth;
	aspect base{ // display settings of the simulation (default is an initial typ)e
		draw shape color:color depth:depth; // draw the shape with the color attri
	}
}

species road{
	rgb color<-#black; 
	
	aspect base{
		draw shape color:color;
	}
	
}

species people skills:[moving]{
	rgb color <- #red; 
	// adding attributes
	building living_place<- nil; //currently these are nil 
	building working_place<- nil;
	int start_work;
	int end_work;
	string objective;
	point the_target<- nil; 
	
	// addede reflexes time to work, and time to go home
	
	reflex time_to_work when: current_date.hour = start_work and objective = "resting"{
			objective <- "working";
			the_target <- any_location_in (working_place);
	}
	reflex time_to_go_home when: current_date.hour = end_work and objective = "working"{
		objective <- "resting";
		the_target <- any_location_in (living_place);
	}
	
	reflex move when: the_target != nil{
		do goto target: the_target on: the_graph;
		
		if the_target = location{
			the_target <- nil;
		}
	}
	aspect base{
		draw circle(10) color:color border:#black;
	}
	
}

experiment Road_traffic_model type: gui {
	parameter "Shapefile for buildings:" var: building0_shape_file category:"GIS";
	parameter "Shapefile for bounds:" var: bounds0_shape_file category:"GIS";
	parameter "Shapefile for roads:" var: road0_shape_file category:"GIS";
	parameter "Number of people agents" var: nb_people category:"People"; // adding for people
	
	//parameter "Speed" var:  avg_speed : 2#m/#s max:10 #m/#s category:"People";
	
	output {
		display city_display type:2d{  // creation of 3D display
			species building aspect:base; // adding building species to the sim
			species road aspect: base; // adding rad species to the sime
			species people aspect: base;
			
		}
		display chart_display refresh: every(10#cycles) type:2d {
			chart "People Objectif" type: pie style:exploded size: {1,0.5} position:{0,0.5}{
				data "working" value: people count(each.objective="working") color: #magenta;
				data "resting" value: people count (each.objective="resting") color:#blue;
				
			}
		}
	}
	
}
