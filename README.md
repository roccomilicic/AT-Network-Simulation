# Auckland Transport Digital Twin Project
## Introduction
This project contains a series of models designed to create a digital twin of Auckland's transport network. The goal is to visualize the simulation in a way that accurately reflects real-world conditions and data. This project was developed for Kenneth Johnson, a lecturer at AUT, who is interested in researching smart cities, specifically Auckland as a smart city.

Key features include:

* Visualization of the Auckland bus transport network using GTFS data for roads and stops.
* Simulations that reflect real-world bus movements based on schedules.
* The potential for further research and development, enabling what-if scenarios to enhance Kenneth's research on smart city infrastructures.

## Prerequisites
To run or scale the simulation, the following are required:

* GAMA IDE: v1.9.3
* Python: v3.10.2 (Note: Python is only needed to scale the simulation, not to run it.)


## Setup Simulation Environment
Follow these steps to set up the simulation environment:

1. Clone or download the project files.
2. Open GAMA IDE and ensure it's running.
3. Import the project into GAMA:
* Right-click on 'User models' → 'Import' → 'GAMA project...'
* Select the project directory you cloned.

## Project Structure
<pre>
  /includes
    / ...                          # Contains all data used to run the model, such as bus data, roads, stops, etc.
/models
    / PrintDate.gaml              # Clock model for the simulation
    / Route38_MultipleBuses.gaml   # Simulates multiple buses following a schedule on Route 38
/scripts
    / calculate_speed.py           # Calculates and sets bus speeds throughout the route
    / create_multiple_trips.py     # Scales the bus trip into a full schedule based on departure times
    / resample_shape_file.py       # Adds more road points for accurate routing
</pre>

## Usage
To run the project locally, follow these steps:

1. Navigate to the /models directory in GAMA IDE.
2. Select the model you want to run (e.g., Route38_MultipleBuses.gaml).
3. Click the green 'main' button to open the simulation.
4. Once in the simulation mode, click the green play button to start.
* You can control the speed of the simulation using the slider tool.
* To restart or stop the simulation, use the available controls in the GAMA interface.
