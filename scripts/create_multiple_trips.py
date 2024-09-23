import pandas as pd
from datetime import datetime, timedelta

# Load the CSV
file_path = '../includes/stop_times_single_Route38.csv'
df = pd.read_csv(file_path)

# Define trip times in a list
trip_times = [
    "04:45", "05:15", "05:45", "06:15", "06:45", "07:00", "07:15", "07:30", "07:45", "08:00",
    "08:15", "08:30", "08:45", "09:00", "09:15", "09:30", "09:45", "10:00", "10:15", "10:30",
    "10:45", "11:00", "11:15", "11:30", "11:45", "12:00", "12:15", "12:30", "12:45", "13:00",
    "13:15", "13:30", "13:45", "14:00", "14:15", "14:30", "14:45", "15:00", "15:15", "15:30",
    "15:45", "16:00", "16:15", "16:30", "16:45", "17:00", "17:15", "17:30", "17:45", "18:00",
    "18:15", "18:30", "18:45", "19:00", "19:15", "19:30", "19:45", "20:00", "20:15", "20:30",
    "20:45", "21:00", "21:15", "21:30", "21:45", "22:00", "22:15", "22:30", "22:45", "23:00",
    "23:15", "23:30", "23:45", "00:00"
]

# Convert trip times into datetime objects for easier manipulation
trip_times_dt = [datetime.strptime(time, "%H:%M") for time in trip_times]

# Function to calculate time differences between stops
def calculate_time_diffs(df):
    time_diffs = []
    prev_time = datetime.strptime(df.iloc[0]['departure_time'], "%H:%M:%S")
    for _, row in df.iterrows():
        current_time = datetime.strptime(row['departure_time'], "%H:%M:%S")
        time_diffs.append(current_time - prev_time)
        prev_time = current_time
    return time_diffs

# Function to shift the stop times for each new trip and add start_stop/end_stop columns
def create_new_trip(df, start_time, time_diffs):
    # Create a copy of the dataframe to avoid modifying the original data
    df_copy = df.copy()
    
    # Add start_stop and end_stop columns and initialize with False
    df_copy['start_stop'] = False
    df_copy['end_stop'] = False
    
    # Set the new start time for the first stop
    current_time = start_time
    for i, diff in enumerate(time_diffs):
        df_copy.at[i, 'arrival_time'] = (current_time + diff).time().strftime("%H:%M:%S")
        df_copy.at[i, 'departure_time'] = (current_time + diff).time().strftime("%H:%M:%S")
        current_time = current_time + diff
    
    # Set the start_stop and end_stop boolean values
    df_copy.at[0, 'start_stop'] = True   # First stop
    df_copy.at[len(df_copy)-1, 'end_stop'] = True  # Last stop
    
    return df_copy

# Calculate the time differences between stops for the first trip
time_diffs = calculate_time_diffs(df)

# Create new trips based on the provided departure times
new_trips = []
for start_time in trip_times_dt:
    new_trip = create_new_trip(df, start_time, time_diffs)
    new_trips.append(new_trip)

# Combine all new trips into a single dataframe
all_trips_df = pd.concat(new_trips, ignore_index=True)

# Save to a new CSV file
output_path = '../includes/stop_times_multiple_Route38.csv'
all_trips_df.to_csv(output_path, index=False)

print(f"New trips saved to {output_path}")
