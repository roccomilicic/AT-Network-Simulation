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

# Function to check if there's a road connection between two points based on shape_id and shape_dist_traveled
def check_road_connection(shape_id1, dist_travel1, shape_id2, dist_travel2):
    # If shape_id changes, there's likely no direct road connection
    if shape_id1 != shape_id2:
        return False

    # If shape_dist_traveled changes significantly, it might indicate a road gap
    distance_difference = abs(dist_travel2 - dist_travel1)
    threshold = 100  # Adjust this threshold as needed
    if distance_difference > threshold:
        return False

    return True

# Define the input and output file paths
input_file = '../includes/gtfs_route_38_35.csv'

# Load CSV data
print(f"Loading CSV data from '{input_file}'...")
try:
    with open(input_file, mode='r') as infile:
        reader = csv.DictReader(infile)
        points = [(row['shape_id'], float(row['shape_pt_lat']), float(row['shape_pt_lon']), float(row['shape_dist_traveled'])) for row in reader]
    print(f"Total points loaded: {len(points)}")
except FileNotFoundError:
    print(f"Error: The file '{input_file}' was not found.")
    exit()
except Exception as e:
    print(f"Error loading file: {e}")
    exit()

# Constants for point generation
fixed_distance = 5  # Fixed distance of 5 meters between shape points
new_points = [(points[0][0], points[0][1], points[0][2], 0)]  # Start with the first point

print("Processing segments...")

# Process each segment between consecutive points
for i in range(1, len(points)):
    shape_id1, lat1, lon1, dist_travel1 = new_points[-1]  # Last point in the new list
    shape_id2, lat2, lon2, dist_travel2 = points[i]  # Current point from the input data

    # Check if there's a road connection between the points
    if check_road_connection(shape_id1, dist_travel1, shape_id2, dist_travel2):
        # Calculate the distance between the last added point and the current point
        distance = haversine(lat1, lon1, lat2, lon2)
        print(f"Distance between point {i-1} and {i}: {distance:.2f} meters")

        # Interpolate new points if the distance is greater than the fixed distance
        while distance > fixed_distance:
            fraction = fixed_distance / distance
            lat1, lon1 = interpolate(lat1, lon1, lat2, lon2, fraction)

            # Add the new point with updated distance traveled
            dist_travel1 += fixed_distance
            new_points.append((shape_id1, lat1, lon1, dist_travel1))
            print(f"Added new interpolated point: ({lat1:.6f}, {lon1:.6f}) with dist_travel={dist_travel1:.2f}")

            # Recalculate the remaining distance to the next point
            distance = haversine(lat1, lon1, lat2, lon2)

        # Add the final point of this segment if it hasn't been added yet
        if distance > 0:
            new_points.append((shape_id2, lat2, lon2, dist_travel2))
            print(f"Added endpoint: ({lat2:.6f}, {lon2:.6f})")
    else:
        print(f"Skipping interpolation between point {i-1} and {i} due to lack of road connection: {shape_id1} -> {shape_id2}")
        new_points.append((shape_id2, lat2, lon2, dist_travel2))

# Write the new shape points back to the same CSV file
print(f"Overwriting CSV data in '{input_file}'...")
try:
    with open(input_file, mode='w', newline='') as outfile:
        writer = csv.writer(outfile)
        writer.writerow(['shape_id', 'shape_pt_lat', 'shape_pt_lon', 'shape_pt_sequence', 'shape_dist_traveled'])

        for i, (shape_id, lat, lon, dist_travel) in enumerate(new_points):
            writer.writerow([shape_id, lat, lon, i + 1, dist_travel])
            print(f"Written point {i+1}: ({lat:.6f}, {lon:.6f})")

    print(f"New shape points successfully written to '{input_file}'")

except Exception as e:
    print(f"Error writing file: {e}")