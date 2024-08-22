import pandas as pd

# Load the CSV file into a DataFrame
df = pd.read_csv('../includes/stop_times_single_Route38.csv')

# Check available columns
print("Available columns:", df.columns)

# Ensure 'shape_dist_traveled' exists
if 'shape_dist_traveled' not in df.columns:
    raise KeyError("Column 'shape_dist_traveled' not found in the DataFrame.")

# Function to convert time strings (HH:MM:SS) to total seconds
def time_to_seconds(time_str):
    h, m, s = map(int, time_str.split(':'))
    return h * 3600 + m * 60 + s

# Calculate the speed between each stop
speeds = []
for i in range(1, len(df)):
    # Time difference in seconds between this stop and the previous stop
    time_diff = time_to_seconds(df.loc[i, 'arrival_time']) - time_to_seconds(df.loc[i-1, 'departure_time'])
    
    # Distance traveled between this stop and the previous stop
    distance_diff = df.loc[i, 'shape_dist_traveled'] - df.loc[i-1, 'shape_dist_traveled']
    
    # Speed = Distance / Time (converted to meters/second)
    if time_diff > 0:
        speed = distance_diff / time_diff
    else:
        speed = 0  # Avoid division by zero

    speeds.append(speed)

# Add the calculated speeds to the DataFrame
df['speed_m_per_s'] = [0] + speeds  # First stop has no speed since there's no previous stop

# Optionally, save the DataFrame to a new CSV file with speeds
df.to_csv('../includes/stop_times_single_Route38.csv', index=False)

print("Speeds calculated and saved to output CSV file.")
