/**
* Name: PrintTime
* Based on the internal empty template. 
* Author: rocco
* Tags: 
*/
model PrintTime

global {
		date starting_date <- date([2024, 8, 12, 0, 0, 0]);
		int zoom <- 4 min:2 max:10;
		float step <- 1#second; 
		
		init {
			write "Starting D&T: " + starting_date;
			write "Day of week: " + starting_date.day_of_week;
			
			create clock {
				current_date <- starting_date;
				
			}
		}

	species clock {
		date current_date update:  date(cycle * step);
		
		string day;
		
		aspect default {
			switch (current_date.day_of_week) {
			    match 1 { day <- "Monday"; }
			    match 2 { day <- "Tuesday"; }
			    match 3 { day <- "Wednesday"; }
			    match 4 { day <- "Thursday"; }
			    match 5 { day <- "Friday"; }
			    match 6 { day <- "Saturday"; }
			    match 7 { day <- "Sunday"; }
			}
			draw string(day + string(current_date, " HH:mm:ss")) size:zoom/2 font:"times" color:#black at:{10, 10, 10};
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

