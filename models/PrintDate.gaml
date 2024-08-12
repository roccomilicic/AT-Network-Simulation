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

	init {
		write "D&T: " + starting_date;
		create clock {
			current_date <- starting_date;
		}

	}

	species clock {
		string current_date;

		aspect default {
			draw string(starting_date) size:zoom/2 font:"times" color:#black at:{10, 10, 10};
		}

	}

}

experiment main type: gui {
	output {
		display myView type: 3d{
			species clock aspect: default;
		}

	}

}

