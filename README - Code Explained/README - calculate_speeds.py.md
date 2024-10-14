#### calculate_speed.py
# Bus Trip Speed Calculation Script
## Overview
This Python script processes a CSV file containing road points for a specific bus route (Route 38) and calculates the distances and speeds between bus stops based on their shape points. The main functionalities of the script include:
*  Interpolating Road Points: It generates approximately 5000 evenly spaced shape points along the bus route.
* Calculating Speeds: It computes the speed between bus stops using the distance traveled and the time taken.

## Functionality
### Interpolation of Road Points
* The script reads a CSV file containing road shape points, calculates the total distance of the route, and divides this distance into segments of a fixed length.
* It generates new points by interpolating between the existing shape points to ensure a uniform distribution.
### Speed Calculation
* After generating the new shape points, the script reads another CSV file containing bus stop arrival and departure times.
* It calculates the speed between each stop based on the distance traveled (using shape distances) and the time difference (using stop times).
* The calculated speeds are added to the stop times CSV file.

## How to Use
### Required Libraries
* Ensure you have the required libraries installed. You can install them using pip:
   *  ```pip install pandas```

### File Structure
The script expects the following file structure:

```
/scripts
  ├── calculate_speeds.py               # The current py file
/includes
  ├── <your-bus-route-roads>.csv        # CSV file containing road points for Route 38
  └── <your-bus-schedule>.csv           # CSV file containing bus stop arrival and departure times
```

### Steps to Replace Files
#### Replace Road Points File: <your-bus-route-roads>.csv

* If you need to use a different road points file, replace the ```input_file``` variable on line 25. Make sure this file is in the includes folder. 
* Ensure the new file contains the following columns: ```shape_pt_lat``` and ```shape_pt_lon```.

#### Replace Stop Times File: <your-bus-schedule>.csv  
* For a different set of bus stop times, replace ```stop_times_file``` variable on line 68. Make sure this file is in the includes folder. 
* Ensure the new file contains ```arrival_time```, ```departure_time```, and ```shape_dist_traveled``` columns.

### Running the Script
    1. Open a terminal and navigate to the directory containing the script.
    2. Run the script using Python: ``` calculate_speed.py```

#### Output
* The script will overwrite the existing ```<your-bus-route-roads>.csv``` file with new interpolated shape points.
* It will also update ```<your-bus-schedule>.csv ``` file to include a new column ```speed_m_per_s```, which contains the calculated speeds between bus stops.

## Notes
* Ensure the input CSV files are formatted correctly and have the required columns.
* The script logs messages to the console upon successful completion of tasks, indicating when new shape points and speeds are written to the files.
