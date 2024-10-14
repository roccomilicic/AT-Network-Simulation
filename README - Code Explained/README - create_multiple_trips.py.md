#### create_multiple_trips.py
# Bus Trip Schedule Generation Script
## Overview
This Python script generates a complete bus schedule by creating multiple trips based on predefined departure times for a specific bus route. It reads stop time data from a CSV file, calculates time differences between stops, and outputs a new CSV file containing all generated trips, replicating a complete bus schedule.

## Functionality
### Key Features
* Load Existing Stop Times: The script reads the existing stop times from a CSV file.
* Calculate Time Differences: It calculates the time differences between each stop to ensure consistent scheduling.
* Generate New Trips: Creates multiple trips based on predefined departure times.
* Output to CSV: Saves the newly generated trips into a new CSV file.

## Input and Output
### Input:
* A CSV file containing the stop times for the initial bus trip, which must include the following columns:
* ```arrival_time```: Time when the bus arrives at the stop (format: HH:MM).
* ```departure_time```: Time when the bus departs from the stop (format: HH:MM).

### Output:
* A new CSV file ```<your-bus-schedule>.csv``` containing all generated trips, with additional columns:
* ```start_stop```: Boolean indicating if the stop is the starting point of a trip.
* ```end_stop```: Boolean indicating if the stop is the endpoint of a trip.

## How to Use
### Required Libraries
* Ensure you have the required libraries installed. You can install them using pip:
   *  ```pip install pandas```

### File Structure
The script expects the following file structure:

```
/scripts
  ├── create_multiple_trips.py          # The current py file
/includes
  └── <your-bus-schedule>.csv           # CSV file containing bus stop arrival and departure times

```

### Steps to Generate the Bus Schedule
#### Prepare the Input File:

    1. Place the <your-bus-schedule>.csv file in the /includes directory.
    2. Ensure the file includes arrival_time and departure_time columns in the correct format.
    3. Modify Departure Times: The script contains a predefined list of departure times. You can modify the trip_times list in the script as needed. 
    NOTE: Departure times for routes can be found on the Auckland Transport website: 
    https://at.govt.nz/bus-train-ferry/timetables#bus.

### Run the Script:
    1. Open a terminal and navigate to the directory containing the script.
    2. Run the script using Python: ```create_multiple_trips.py```

### Output
The script will generate a new file in the ```/includes``` directory, which contains the schedules for all generated trips.

## Notes
* The script is designed to create trips using the same sequence of stops with varying start times.
* Ensure the input CSV file is formatted correctly to avoid errors during loading and processing.