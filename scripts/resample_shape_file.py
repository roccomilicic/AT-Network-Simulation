import csv
import math

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

# Define the input and output file paths
input_file = '../includes/gtfs_Route_38.csv'

# Load CSV data
print(f"Loading CSV data from '{input_file}'...")
try:
    with open(input_file, mode='r') as infile:
        reader = csv.DictReader(infile)
        points = [(float(row['shape_pt_lat']), float(row['shape_pt_lon'])) for row in reader]

    print(f"Total points loaded: {len(points)}")
except FileNotFoundError:
    print(f"Error: The file '{input_file}' was not found.")
    exit()
except Exception as e:
    print(f"Error loading file: {e}")
    exit()

fixed_distance = 50  # Distance between shape points in meters
new_points = [points[0]]  # Start with the first point
print("Processing segments...")

# Process each segment between consecutive points
for i in range(1, len(points)):
    lat1, lon1 = new_points[-1]
    lat2, lon2 = points[i]
    
    # Calculate the distance between the last added point and the current point
    distance = haversine(lat1, lon1, lat2, lon2)
    print(f"Distance between point {i-1} and {i}: {distance:.2f} meters")
    
    # Interpolate new points if the distance is greater than the fixed distance
    while distance > fixed_distance:
        fraction = fixed_distance / distance
        lat1, lon1 = interpolate(lat1, lon1, lat2, lon2, fraction)
        
        # Calculate the distance to the next point
        next_distance = haversine(lat1, lon1, lat2, lon2)
        
        # Only add the new point if it's appropriately spaced from the previous one
        if next_distance >= fixed_distance:
            new_points.append((lat1, lon1))
            print(f"Added new interpolated point: ({lat1:.6f}, {lon1:.6f})")
        distance = next_distance
    
    # Add the final point of this segment if it hasn't been added already
    if distance > 0 and distance >= fixed_distance:
        new_points.append((lat2, lon2))
        print(f"Added endpoint: ({lat2:.6f}, {lon2:.6f})")

# Write the new shape points back to the same CSV file
print(f"Overwriting CSV data in '{input_file}'...")
try:
    with open(input_file, mode='w', newline='') as outfile:
        writer = csv.writer(outfile)
        writer.writerow(['shape_id', 'shape_pt_lat', 'shape_pt_lon', 'shape_pt_sequence', 'shape_dist_traveled'])
        
        for i, (lat, lon) in enumerate(new_points):
            writer.writerow([f'new_shape_id', lat, lon, i + 1, i * fixed_distance])
            print(f"Written point {i+1}: ({lat:.6f}, {lon:.6f})")

    print(f"New shape points successfully written to '{input_file}'")

except Exception as e:
    print(f"Error writing file: {e}")
