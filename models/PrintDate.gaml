/**
* Name: PrintTime
* Based on the internal empty template. 
* Author: rocco
* Tags: 
*/
model PrintTime

global {

	date starting_date <- date([2024, 8, 12, 12, 0, 0]);
	int zoom <- 4 min:2 max:10;
	float step <- 2#second; init {
	write "D&T: " + starting_date;
	
		create clock {
			current_date <- starting_date;
		}

	}

	species clock {
		date current_date update:  date(cycle * step);
		
		aspect default {
			draw string(current_date) size:zoom/2 font:"times" color:#black at:{10, 10, 10};
		}

	}
}

experiment main type: gui {
	output {
		display myView type: 3d {
			species clock aspect: default;
		}
	}
}

