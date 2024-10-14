#### MultipleRoutes.gaml
# Multiple Routes Simulation

## Overview
This model simulates buses moving on two routes adhering to their respective schedules
## Features
* Buses on multiple routes: A bus on each route will depart based on a scheduled time and set speeds.
* Route Representation: The road and stop data for the bus route are imported from GTFS files.
* Scheduled Movements: Buses move along the route based on scheduled departure and arrival times.
* Simulation Clock: A clock governs the simulation, which updates in real-time as the buses move along the route.
* Graph-Based Routing: The road network is built as a directed graph, enabling buses to follow realistic paths between stops.

## Project Structure
```


/models
  └── MultipleRoutes.gaml        # Main GAMA model for visualizing multiple routes with buses
```

## How the Code Works
### Global Section

#### Clock Attributes:
* step: Controls the time increment of the simulation (1 second per step).
* starting_date: The start date and time for the simulation.
Import GTFS Data:

#### GTFS data for Route 38 and 35 is imported from several files:
* stops38_35.csv: Contains the bus stop information.
* gtfs_route_38_35.csv: Contains road coordinates.
* route_38_trips: Defines a bus for route 38 trips including departure times and speeds.
* route_35_trips: Defines a bus for route 35 trips including departure times and speeds.

#### Graph Creation:
* The graphs variable creates a list of directed graphs from the road data for buses to follow. One for each route

#### Initialization
* Bus Stops: Stops are created from the stops.csv file. Each stop is assigned a longitude (lon), latitude (lat), and stop name.
* Road Points: Road points are created by looping over the road data, connecting each road point to the next, forming a road network.
* Bus Schedule: A list of bus start times and their sequences is created from the file.

### Reflexes and Actions

#### Bus Departure Check:
* This reflex (check_bus_departure) runs every step of the simulation to check if a bus is scheduled to depart at the current time. If a bus is ready, the create_bus action is triggered to create and launch the bus.

#### Bus Creation:
Two buses are created. One for route 38 and one for route 35.

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
