/**
* Name: PrintDate
* Based on the internal empty template. 
* Author: rocco
* Tags: 
*/


model PrintDate
global {
	
	//definition of the date of begining of the simulation - defining this date will allows to change the normal date management of the simulation by a more realistic one (using calendar) 
	date starting_date <- date([2024,8,12,12,0,0]);
	
	//be careful, when real dates are used, modelers should not use the #month and #year values that are not consistent with them
	//#ms, #s, #mn, #h, #day represent exact durations that can be used in combination with the date values
	
	
	//float step <- 2#year; ssss
		
	init {
		write "D&T: " + starting_date;
		

	}
	
	species clock {
		string current_date;
		
		
	}

}

experiment main type: gui;
