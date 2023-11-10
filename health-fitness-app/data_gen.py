import sqlite3
from faker import Faker
import random
from datetime import datetime, timedelta

# Initialize Faker
fake = Faker()

# Connect to the SQLite database
conn = sqlite3.connect('health_fitness_app.db')
cursor = conn.cursor()

# Execute the SQL file content to set up the database schema
with open('fitness.sql', 'r') as file:
    sql_file_content = file.read()
    sql_commands = sql_file_content.split(';')
    for command in sql_commands:
        if command.strip():
            cursor.execute(command)
    conn.commit()

# Number of sample records to generate
num_users = 100
num_workouts_per_user = 200
num_nutrition_logs_per_user = 200
num_food_items_per_log = 10
num_sleep_logs_per_user = 200
num_health_metrics_per_user = 200

# Define a list of food items
food_items_list = ["Pasta", "Pizza", "Burger", "Salad", "Steak", "Fish", "Chicken", "Sandwich", "Rice", "Beans"]

# Generate Users
try:
    conn.execute('BEGIN TRANSACTION;')
    for _ in range(num_users):
        cursor.execute("""
        INSERT INTO Users (Username, Password, Email, DateOfBirth, Gender, Height, Weight, FitnessGoals, HealthConditions, AccountCreationDate)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            fake.user_name(),
            fake.password(),
            fake.email(),
            fake.date_of_birth(minimum_age=18, maximum_age=65),
            random.choice(['Male', 'Female', 'Other']),
            random.uniform(1.5, 2.0),
            random.uniform(50, 100),
            random.choice(["Lose weight", "Build muscle", "Improve stamina", "Increase flexibility"]),
            random.choice(["None", "Asthma", "Diabetes", "Hypertension"]),
            fake.date_this_decade()
        ))
    conn.commit()
except sqlite3.Error as e:
    conn.rollback()
    print(f"An error occurred while inserting users: {e}")

# Fetch all user IDs
user_ids = [row[0] for row in cursor.execute("SELECT UserID FROM Users")]

# Generate Workouts with varied intensity, duration, and stress-related notes
stress_keywords = ['stress', 'pressure', 'tense', 'demanding', 'overwhelm']
try:
    conn.execute('BEGIN TRANSACTION;')
    for user_id in user_ids:
        for _ in range(num_workouts_per_user):
            workout_date = fake.date_between(start_date='-1y', end_date='today')
            duration = random.uniform(15, 120)
            intensity = random.choice(['Low', 'Medium', 'High'])
            note = "Good workout session." if not random.choice([True, False]) else f"Good workout session. Felt {random.choice(stress_keywords)} due to workload."
            cursor.execute("""
            INSERT INTO Workouts (UserID, Date, WorkoutType, Duration, Intensity, CaloriesBurned, Notes)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """, (
                user_id,
                workout_date.strftime('%Y-%m-%d'),
                random.choice(['Cardio', 'Strength', 'Flexibility', 'Aerobic', 'Anaerobic']),
                duration,
                intensity,
                random.uniform(100, 1000),
                note
            ))
    conn.commit()
except sqlite3.Error as e:
    conn.rollback()
    print(f"An error occurred while inserting workouts: {e}")
# Define a list of food items
food_items_list = ["Pasta", "Pizza", "Burger", "Salad", "Steak", "Fish", "Chicken", "Sandwich", "Rice", "Beans"]

# Generate Nutrition Logs and Food Items with corresponding Micronutrients
try:
    for user_id in user_ids:
        # Start a transaction for the current user's nutrition logs
        conn.execute('BEGIN TRANSACTION;')

        for i in range(num_nutrition_logs_per_user):
            log_date = fake.date_between(start_date='-1y', end_date='today')
            total_caloric_intake = random.uniform(1000, 3000) if random.choice([True, False]) else None
            water_intake = random.uniform(1, 4) if total_caloric_intake is not None else None
            
            cursor.execute("""
            INSERT INTO NutritionLogs (UserID, Date, TotalCaloricIntake, WaterIntake)
            VALUES (?, ?, ?, ?)
            """, (
                user_id,
                log_date.strftime('%Y-%m-%d'),
                total_caloric_intake,
                water_intake
            ))
            nutrition_log_id = cursor.lastrowid

            # Generate Food Items for each NutritionLog
            for _ in range(num_food_items_per_log):
                food_name = random.choice(food_items_list)
                portion_size = random.uniform(100, 500)
                calories = random.uniform(100, 800)
                
                cursor.execute("""
                INSERT INTO FoodItems (NutritionLogID, FoodName, PortionSize, Calories)
                VALUES (?, ?, ?, ?)
                """, (
                    nutrition_log_id,
                    food_name,
                    portion_size,
                    calories
                ))
                food_item_id = cursor.lastrowid

                # Generate Micronutrients for each FoodItem
                vitamin_a = random.choice([0, 500, 1000])
                vitamin_c = random.choice([0, 60, 120])
                calcium = random.choice([0, 900, 1800])
                iron = random.choice([0, 14, 28])

                cursor.execute("""
                INSERT INTO Micronutrients (FoodItemID, VitaminA, VitaminC, Calcium, Iron)
                VALUES (?, ?, ?, ?, ?)
                """, (
                    food_item_id,
                    vitamin_a,
                    vitamin_c,
                    calcium,
                    iron
                ))
        
        # Commit the transaction after all nutrition logs for the user are inserted
        conn.commit()

except sqlite3.Error as e:
    # If an error occurs, roll back the transaction
    conn.rollback()
    print(f"An error occurred while inserting nutrition data for user {user_id}: {e}")

# Generate Sleep Logs with varied sleep quality and duration
try:
    for user_id in user_ids:
        conn.execute('BEGIN TRANSACTION;')  # Start a transaction for the current user's sleep logs
        for _ in range(num_sleep_logs_per_user):
            sleep_date = fake.date_between(start_date='-1y', end_date='today')
            time_to_bed = datetime.combine(sleep_date, datetime.min.time()) + timedelta(hours=random.randint(21, 23), minutes=random.randint(0, 59))
            wake_up_time = time_to_bed + timedelta(hours=random.uniform(4, 10))
            sleep_duration = (wake_up_time - time_to_bed).seconds / 3600
            sleep_quality = random.randint(1, 10)
            cursor.execute("""
            INSERT INTO SleepLogs (UserID, Date, TimeToBed, WakeUpTime, SleepDuration, SleepQualityScore)
            VALUES (?, ?, ?, ?, ?, ?)
            """, (
                user_id,
                sleep_date.strftime('%Y-%m-%d'),
                time_to_bed.strftime('%H:%M:%S'),
                wake_up_time.strftime('%H:%M:%S'),
                sleep_duration,
                sleep_quality
            ))
        conn.commit()  # Commit the transaction after inserting all sleep logs for the user
except sqlite3.Error as e:
    conn.rollback()  # Rollback the transaction if any error occurs
    print(f"An error occurred while inserting sleep logs for user {user_id}: {e}")

# Generate Health Metrics with significant weight changes for some users
try:
    for user_id in user_ids:
        conn.execute('BEGIN TRANSACTION;')  # Start a transaction for the current user's health metrics
        weight = random.uniform(50, 100)
        for _ in range(num_health_metrics_per_user):
            metric_date = fake.date_between(start_date='-1y', end_date='today')
            weight += random.uniform(-1, 1)  # Simulate weight fluctuation
            cursor.execute("""
            INSERT INTO HealthMetrics (UserID, Date, Weight, BodyFatPercentage, BloodPressure, GlucoseLevels, CholesterolLevels)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """, (
                user_id,
                metric_date.strftime('%Y-%m-%d'),
                weight,
                random.uniform(10, 30),
                f"{random.randint(110, 140)}/{random.randint(70, 90)}",
                random.uniform(70, 130),
                random.uniform(150, 250)
            ))
        conn.commit()  # Commit the transaction after inserting all health metrics for the user
except sqlite3.Error as e:
    conn.rollback()  # Rollback the transaction if any error occurs
    print(f"An error occurred while inserting health metrics for user {user_id}: {e}")


# Close the connection
conn.close()
