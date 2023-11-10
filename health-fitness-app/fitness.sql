-- Users Table
CREATE TABLE Users (
    UserID INTEGER PRIMARY KEY AUTOINCREMENT,
    Username TEXT NOT NULL,
    Password TEXT NOT NULL, -- Hashed and Salted
    Email TEXT NOT NULL UNIQUE,
    DateOfBirth DATE,
    Gender TEXT,
    Height REAL,
    Weight REAL,
    FitnessGoals TEXT,
    HealthConditions TEXT,
    AccountCreationDate DATE DEFAULT CURRENT_DATE
);
-- An index on Email is automatically created due to the UNIQUE constraint

-- Workouts Table
CREATE TABLE Workouts (
    WorkoutID INTEGER PRIMARY KEY AUTOINCREMENT,
    UserID INTEGER,
    Date DATE,
    WorkoutType TEXT,
    Duration REAL, -- in minutes
    Intensity TEXT, -- e.g., Low, Medium, High
    CaloriesBurned REAL,
    Notes TEXT,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
CREATE INDEX idx_workouts_userid_date ON Workouts(UserID, Date);

-- Exercises Table (New Table)
CREATE TABLE Exercises (
    ExerciseID INTEGER PRIMARY KEY AUTOINCREMENT,
    WorkoutID INTEGER,
    Name TEXT,
    Sets INTEGER,
    Reps INTEGER,
    Weight REAL,
    FOREIGN KEY (WorkoutID) REFERENCES Workouts(WorkoutID)
);
CREATE INDEX idx_exercises_workoutid ON Exercises(WorkoutID);

-- NutritionLogs Table
CREATE TABLE NutritionLogs (
    NutritionLogID INTEGER PRIMARY KEY AUTOINCREMENT,
    UserID INTEGER,
    Date DATE,
    TotalCaloricIntake REAL,
    WaterIntake REAL, -- in liters
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
CREATE INDEX idx_nutritionlogs_userid_date ON NutritionLogs(UserID, Date);

-- FoodItems Table
CREATE TABLE FoodItems (
    FoodItemID INTEGER PRIMARY KEY AUTOINCREMENT,
    NutritionLogID INTEGER,
    FoodName TEXT,
    PortionSize REAL,
    Calories REAL,
    Macronutrients TEXT,
    Micronutrients TEXT,
    Notes TEXT, -- New column for additional details
    FOREIGN KEY (NutritionLogID) REFERENCES NutritionLogs(NutritionLogID)
);
CREATE INDEX idx_fooditems_nutritionlogid ON FoodItems(NutritionLogID);

-- Macronutrients Table (New Table)
CREATE TABLE Macronutrients (
    MacroID INTEGER PRIMARY KEY AUTOINCREMENT,
    FoodItemID INTEGER,
    Protein REAL,
    Carbs REAL,
    Fats REAL,
    FOREIGN KEY (FoodItemID) REFERENCES FoodItems(FoodItemID)
);
-- Assuming queries often join Macronutrients with FoodItems, we add an index
CREATE INDEX idx_macronutrients_fooditemid ON Macronutrients(FoodItemID);

-- Micronutrients Table (New Table)
CREATE TABLE Micronutrients (
    MicroID INTEGER PRIMARY KEY AUTOINCREMENT,
    FoodItemID INTEGER,
    VitaminA REAL,
    VitaminC REAL,
    Calcium REAL,
    Iron REAL,
    FOREIGN KEY (FoodItemID) REFERENCES FoodItems(FoodItemID)
);
-- Assuming queries often join Micronutrients with FoodItems, we add an index
CREATE INDEX idx_micronutrients_fooditemid ON Micronutrients(FoodItemID);

-- SleepLogs Table (Updated to remove SleepCycles text field)
CREATE TABLE SleepLogs (
    SleepLogID INTEGER PRIMARY KEY AUTOINCREMENT,
    UserID INTEGER,
    Date DATE,
    TimeToBed TIME,
    WakeUpTime TIME,
    SleepDuration REAL, -- in hours
    Interruptions INTEGER,
    SleepQualityScore INTEGER, -- e.g., on a scale of 1 to 10
    Notes TEXT,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
CREATE INDEX idx_sleeplogs_userid_date ON SleepLogs(UserID, Date);

-- SleepCycles Table (New Table)
CREATE TABLE SleepCycles (
    SleepCycleID INTEGER PRIMARY KEY AUTOINCREMENT,
    SleepLogID INTEGER,
    CycleType TEXT, -- e.g., Deep, REM, Light
    Duration REAL, -- in hours
    FOREIGN KEY (SleepLogID) REFERENCES SleepLogs(SleepLogID)
);
CREATE INDEX idx_sleepcycles_sleeplogid ON SleepCycles(SleepLogID);

-- HealthMetrics Table
CREATE TABLE HealthMetrics (
    MetricsID INTEGER PRIMARY KEY AUTOINCREMENT,
    UserID INTEGER,
    Date DATE,
    Weight REAL,
    BodyFatPercentage REAL,
    BloodPressure TEXT, -- e.g., "120/80"
    GlucoseLevels REAL,
    CholesterolLevels REAL,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
CREATE INDEX idx_healthmetrics_userid_date ON HealthMetrics(UserID, Date);

-- UserGoals Table (New Table)
CREATE TABLE UserGoals (
    GoalID INTEGER PRIMARY KEY AUTOINCREMENT,
    UserID INTEGER,
    Goal TEXT,
    TargetDate DATE,
    AchievementStatus TEXT, -- e.g., Not Started, In Progress, Achieved
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
-- An index might be useful if queries filter or sort by TargetDate or AchievementStatus
CREATE INDEX idx_usergoals_userid_targetdate ON UserGoals(UserID, TargetDate);
