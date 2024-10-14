#### PrintDate.gaml
# PrintDate Clock Model
## Overview
The PrintTime model is a clock simulation designed to display the current day of the week and the time during the simulation. This model provides a visual representation of the simulation's temporal context, updating the time dynamically as the simulation progresses.

## Code Description
### Global Variables
*starting_date: Sets the initial date and time for the simulation. In this case, it is initialized to August 12, 2024.
* zoom: Defines the size of the text displayed on the screen, with a range from 2 to 10.
* step: Represents the time increment for each cycle of the simulation, set to 1 second.

### Initialization
During the initialization phase:

* The starting date and day of the week are logged to the console.
* A clock species is created, which will manage the current date throughout the simulation.

### Clock Species
The clock species contains the following components:

* current_date: Updates the current date based on the simulation's time cycle.
* day: A string that stores the name of the current day of the week.

### Aspect Default
The ```aspect default``` section defines how the clock will be displayed:

* A switch statement determines the day of the week based on current_date.day_of_week and assigns the appropriate day name to the day variable.
* The clock then draws the string that includes both the day name and the current time formatted as HH:mm:ss at a specified position on the screen.

## Experiment Configuration
* The main experiment is of type gui, which allows for a graphical user interface.
* It outputs a 3D display of the clock species, showcasing the time and day dynamically.
