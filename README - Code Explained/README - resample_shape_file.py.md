#### resample_shape_file.py
# Road Points Interpolation Script
## Overview
This Python script processes a CSV file containing road shape points for a bus route. It performs the following main tasks:

* Haversine Distance Calculation: Calculates the distance between two geographical points.
* Point Interpolation: Interpolates additional shape points between existing points based on a fixed distance.
* Road Connection Check: Checks for road connectivity between consecutive points based on shape ID and distance traveled.

## Functionality
### Key Functions
* Haversine: Computes the distance between two latitude/longitude points.
* Interpolate: Generates new points between two existing points based on a specified fraction.
* Check Road Connection: Verifies whether two points are connected based on their shape ID and traveled distance.


## Input and Output
### Input:
* A CSV file containing road shape points, which must include the following columns:
    * shape_id: Identifier for the shape.
    * shape_pt_lat: Latitude of the shape point.
    * shape_pt_lon: Longitude of the shape point.
    * shape_dist_traveled: Distance traveled along the shape.

### Output:

* The script overwrites the original CSV file with new interpolated shape points, adding new points while maintaining the existing data structure.


## How to Use
### Required Libraries
* Ensure you have Python installed on your machine. This script uses the built-in csv and math libraries, so no additional packages are required.

### File Structure
The script expects the following file structure:

```
/scripts
  ├── resample_shape_file.py            # The current py file
/includes
  ├── <your-bus-route-roads>.csv        # CSV file containing road points for the route 
```

###Steps to Replace the Road Points File
* Update the Input File:
Replace ```input_file``` on line 38 with the road points csv file you want to update.
* Ensure the file contains the necessary columns: shape_id, shape_pt_lat, shape_pt_lon, and shape_dist_traveled.


### Running the Script
1. Open a terminal and navigate to the directory containing the script.
2. Run the script using Python:
### Running the Script
    1. Open a terminal and navigate to the directory containing the script.
    2. Run the script using Python: ``` resample_shape_file.py```


### Output
* The script will overwrite the existing ```<your-bus-route-roads>.csv```  file with new interpolated shape points.
* During execution, it will print messages to the console detailing the processing steps, including distances calculated, new points added, and any skipped interpolations.
Notes
* The script includes a threshold for checking road connections, which can be adjusted in the ```check_road_connection``` function if needed.
* Ensure the input CSV file is formatted correctly to avoid errors during loading and processing.
* The fixed distance for interpolation is set to 5 meters, which can be modified by changing the ```fixed_distance``` variable in the script.