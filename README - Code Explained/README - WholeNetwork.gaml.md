#### WholeNetwork.gaml
# WholeNetwork

## Overview
This model simulates the whole network without any buses. It show all the stops and 

## Features
* Route Representation: The road and stop data for the bus route are imported from GTFS files using all the available data.
* Simulation Clock: A clock governs the simulation, which updates in real-time as the buses move along the route.

## Project Structure
```
/includes
  ├── stops_all.csv                      # CSV file for bus stops on the route
  ├── shapes_all.csv                     # CSV file containing road data

/models
  └── WholeNetwork.gaml        # Main GAMA model for visualizing the whole network
```

## How the Code Works
### Global Section

#### Clock Attributes:
* step: Controls the time increment of the simulation (1 second per step).
* starting_date: The start date and time for the simulation.
Import GTFS Data:

#### GTFS data for the network is imported from several files:
* stops_csv: Contains the bus stop information.
* roads_csv: Contains road coordinates.


#### Initialization
* Bus Stops: Stops are created from the stops.csv file. Each stop is assigned a longitude (lon), latitude (lat), and stop name.
* Road Points: Road points are created by looping over the road data, connecting each road point to the next, forming a road network.


### Key Species
#### Stop
* The stop species represents the bus stops along the route. Stops are displayed as yellow circles on the map.
#### Road
* The road species represents the road segments connecting bus stops. Roads are displayed as red lines with links between consecutive road points.
#### Clock
* The clock species keeps track of the current time in the simulation. It updates every simulation step and displays the current day and time on the screen.
