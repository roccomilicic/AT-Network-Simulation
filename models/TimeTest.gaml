model TimeTest

global {
    
    //definition of the date of begining of the simulation - defining this date will allows to change the normal date management of the simulation by a more realistic one (using calendar) 
    date starting_date <- date([2024,8,12,12,0,0]);
    date current_date <- starting_date;
    float step <- 2#second;
    
    //be careful, when real dates are used, modelers should not use the #month and #year values that are not consistent with them
    //#ms, #s, #mn, #h, #day represent exact durations that can be used in combination with the date values
        
    init {
        write "Starting date: " + starting_date;
    }
    
    reflex updated_time {
    	write "Time elapsed after " + cycle + " cycles: " + string(current_date, "dd MMMM yyyy HH:mm:ss");
    }

}

experiment main type: gui;
