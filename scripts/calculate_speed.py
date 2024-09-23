import pandas as pd
import math
import csv

# Function to calculate the Haversine distance between two points in meters
def haversine(lat1, lon1, lat2, lon2):
    R = 6371000  # Radius of Earth in meters
    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    delta_phi = math.radians(lat2 - lat1)
    delta_lambda = math.radians(lon2 - lon1)
    
    a = math.sin(delta_phi / 2) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(delta_lambda / 2) ** 2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    
    return R * c

# Function to interpolate between two points
def interpolate(lat1, lon1, lat2, lon2, fraction):
    lat = lat1 + (lat2 - lat1) * fraction
    lon = lon1 + (lon2 - lon1) * fraction
    return lat, lon

# Load the road points CSV
input_file = '../includes/gtfs_route_38_35.csv'
df = pd.read_csv(input_file)

# Convert the DataFrame to a list of tuples for processing
points = [(row['shape_pt_lat'], row['shape_pt_lon']) for _, row in df.iterrows()]

# Adjust the desired number of points to produce around 5000 points
desired_num_points = 5000  # Target number of points
total_distance = sum(haversine(points[i][0], points[i][1], points[i+1][0], points[i+1][1]) for i in range(len(points) - 1))
fixed_distance = total_distance / desired_num_points

# Create new points array with interpolated points
new_points = [points[0]]  # Start with the first point

for i in range(1, len(points)):
    lat1, lon1 = new_points[-1]
    lat2, lon2 = points[i]
    
    # Calculate the distance between the last added point and the current point
    distance = haversine(lat1, lon1, lat2, lon2)
    
    # Interpolate new points if the distance is greater than the fixed distance
    while distance > fixed_distance:
        fraction = fixed_distance / distance
        lat1, lon1 = interpolate(lat1, lon1, lat2, lon2, fraction)
        new_points.append((lat1, lon1))
        distance = haversine(lat1, lon1, lat2, lon2)
    
    # Add the final point of this segment if it hasn't been added already
    if distance > 0:
        new_points.append((lat2, lon2))

# Write the new shape points back to the same CSV file
with open(input_file, mode='w', newline='') as outfile:
    writer = csv.writer(outfile)
    writer.writerow(['shape_id', 'shape_pt_lat', 'shape_pt_lon', 'shape_pt_sequence', 'shape_dist_traveled'])
    
    for i, (lat, lon) in enumerate(new_points):
        writer.writerow([f'new_shape_id', lat, lon, i + 1, i * fixed_distance])

print(f"New shape points successfully written to '{input_file}'")

# Load the stop times CSV file into a DataFrame
stop_times_file = '../includes/route38_35_bus_times.csv'
df_stops = pd.read_csv(stop_times_file)

# Function to convert time strings (HH:MM:SS) to total seconds
def time_to_seconds(time_str):
    h, m, s = map(int, time_str.split(':'))
    return h * 3600 + m * 60 + s

# Calculate the speed between each stop
speeds = []
for i in range(1, len(df_stops)):
    # Time difference in seconds between this stop and the previous stop
    time_diff = time_to_seconds(df_stops.loc[i, 'arrival_time']) - time_to_seconds(df_stops.loc[i-1, 'departure_time'])
    
    # Distance traveled between this stop and the previous stop
    distance_diff = df_stops.loc[i, 'shape_dist_traveled'] - df_stops.loc[i-1, 'shape_dist_traveled']
    
    # Speed = Distance / Time (converted to meters/second)
    if time_diff > 0:
        speed = distance_diff / time_diff
    else:
        speed = 0  # Avoid division by zero

    speeds.append(speed)

# Add the calculated speeds to the DataFrame
df_stops['speed_m_per_s'] = [0] + speeds  # First stop has no speed since there's no previous stop

# Overwrite the original CSV file with the new data
df_stops.to_csv(stop_times_file, index=False)

print("Speeds calculated and saved to the original CSV file.")
