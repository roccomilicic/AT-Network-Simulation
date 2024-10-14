#### Route38_MultipleBuses.gaml
# Route 38 Multiple Buses Simulation

## Overview
This model simulates multiple buses moving in both directions along Route 38 based on a bus schedule. It uses GTFS (General Transit Feed Specification) data to create the road network, stops, and bus schedules, allowing buses to move realistically through the route. This GAMA simulation is designed to help visualize and analyze bus movements as they follow scheduled departure times.

## Features
* Multiple Buses: Buses depart according to a timetable, moving in both directions on Route 38.
* Route Representation: The road and stop data for the bus route are imported from GTFS files.
* Scheduled Movements: Buses move along the route based on scheduled departure and arrival times.
* Simulation Clock: A clock governs the simulation, which updates in real-time as the buses move along the route.
* Graph-Based Routing: The road network is built as a directed graph, enabling buses to follow realistic paths between stops.

## Project Structure
```
/includes
  ├── Route_38_Stops.shp                # Shapefile for the bounds of Route 38
  ├── stops.csv                          # CSV file for bus stops on the route
  ├── gtfs_Route_38.csv                  # CSV file containing road data
  └── stop_times_multiple_Route38.csv    # CSV file containing multiple trips data (departure times, stop sequences, speeds, etc.)

/models
  └── Route_38_MultipleBuses.gaml        # Main GAMA model for visualizing multiple buses on Route 38
```

## How the Code Works
### Global Section

#### Clock Attributes:
* step: Controls the time increment of the simulation (1 second per step).
* starting_date: The start date and time for the simulation.
Import GTFS Data:

#### GTFS data for Route 38 is imported from several files:
* route_38_bounds: Defines the geographic bounds of the route using a shapefile.
* route_38_stops_csv: Contains the bus stop information.
* route_38_road_csv: Contains road coordinates.
* multiple_route_38_trips: Defines multiple bus trips including departure times and speeds.

#### Graph Creation:
* The route_38_roads and route_38_roads_reversed matrices represent the roads in both directions.
* The the_graph variable creates a directed graph from the road data for buses to follow.

#### Initialization
* Bus Stops: Stops are created from the stops.csv file. Each stop is assigned a longitude (lon), latitude (lat), and stop name.
* Road Points: Road points are created by looping over the road data, connecting each road point to the next, forming a road network.
* Bus Schedule: A list of bus start times and their sequences is created from the stop_times_multiple_Route38.csv file.

### Reflexes and Actions

#### Bus Departure Check:
* This reflex (check_bus_departure) runs every step of the simulation to check if a bus is scheduled to depart at the current time. If a bus is ready, the create_bus action is triggered to create and launch the bus.

#### Bus Creation:
* For each departure, two buses are created—one traveling in the original direction, and one traveling in reverse. Each bus is assigned a path, a departure schedule, arrival times, and speeds.

#### Bus Movement:
* The buses move along the road network, following the predefined path and speeds between stops. The simulation updates the position of the buses every step, checking if they have reached the next stop.

### Key Species
#### Bus
* The bus species represents the buses in the simulation. Buses follow a path (bus_path) and move between stops based on speeds specified in the GTFS data. The buses are displayed as rectangles moving along the road network.
#### Stop
* The stop species represents the bus stops along the route. Stops are displayed as yellow circles on the map.
#### Road
* The road species represents the road segments connecting bus stops. Roads are displayed as red lines with links between consecutive road points.
#### Clock
* The clock species keeps track of the current time in the simulation. It updates every simulation step and displays the current day and time on the screen.
