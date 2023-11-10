-- 1. Retrieve a detailed summary of workouts for the past week with descriptive details
SELECT 
  'On ' || Date || ', you did ' || WorkoutType || ' workouts for a total of ' || 
  ROUND(SUM(Duration), 2) || ' minutes across ' || COUNT(WorkoutType) || ' sessions, ' ||
  'with an average intensity level of ' || ROUND(AVG(Intensity), 2) || 
  ' and burned a total of ' || SUM(CaloriesBurned) || ' calories.' AS WorkoutSummary
FROM Workouts
WHERE UserID = ? AND Date BETWEEN date('now', '-7 days') AND date('now')
GROUP BY Date, WorkoutType
ORDER BY Date;


-- 2. Calculate calories burned versus calories consumed over the past week
SELECT 'In the past week, you burned ' || SUM(w.CaloriesBurned) || ' calories and consumed ' || 
       (SELECT SUM(n.TotalCaloricIntake) FROM NutritionLogs n WHERE n.UserID = w.UserID AND n.Date BETWEEN date('now', '-7 days') AND date('now')) || ' calories.' AS CalorieComparison
FROM Workouts w
WHERE UserID = ? AND Date BETWEEN date('now', '-7 days') AND date('now');

-- 3. List foods contributing most to fat intake over the past month with frequency
SELECT FoodName || ' (' || ROUND(SUM(Calories), 2) || ' calories, eaten ' || COUNT(FoodName) || ' times)' AS FoodDetail
FROM FoodItems fi
INNER JOIN NutritionLogs nl ON fi.NutritionLogID = nl.NutritionLogID
WHERE nl.UserID = ? AND nl.Date BETWEEN date('now', '-30 days') AND date('now')
GROUP BY FoodName
ORDER BY SUM(Calories) DESC
LIMIT 5;




-- 4. Alert for significant weight change over the past month
SELECT CASE 
     WHEN WeightChange > 5 THEN 'Significant weight increase by ' || WeightChange || ' kg over the past month.'
     WHEN WeightChange < -5 THEN 'Significant weight decrease by ' || ABS(WeightChange) || ' kg over the past month.'
     ELSE 'Your weight has been stable over the past month.'
END AS WeightChangeAlert
FROM (
    SELECT MAX(Weight) - MIN(Weight) AS WeightChange
    FROM HealthMetrics
    WHERE UserID = ? AND Date BETWEEN date('now', '-30 days') AND date('now')
);

-- 5. Evaluate sleep quality over the past month
SELECT 'Your average sleep quality score over the past month is ' || AVG(SleepQualityScore) || '.' AS AverageSleepQuality
FROM SleepLogs
WHERE UserID = ? AND Date BETWEEN date('now', '-30 days') AND date('now');

-- 6. Check for hydration levels based on water intake
SELECT CASE 
     WHEN AVG(WaterIntake) < 2 THEN 'Possible dehydration warning: Your average daily water intake over the past week was ' || AVG(WaterIntake) || ' liters.'
     WHEN AVG(WaterIntake) > 3 THEN 'Good hydration: Your average daily water intake over the past week was ' || AVG(WaterIntake) || ' liters.'
     ELSE 'Normal hydration: Your average daily water intake over the past week was ' || AVG(WaterIntake) || ' liters.'
END AS HydrationLevel
FROM NutritionLogs
WHERE UserID = ? AND Date BETWEEN date('now', '-7 days') AND date('now');

-- 7. Identify days with incomplete nutrition logs
SELECT 'You missed logging your nutrition on the following dates: ' || GROUP_CONCAT(Date, ', ') AS MissingLogs
FROM NutritionLogs
WHERE UserID = ? AND TotalCaloricIntake IS NULL AND Date BETWEEN date('now', '-30 days') AND date('now');

-- 8. Analyze exercise variety to promote a balanced workout regimen
SELECT 'Your workout variety over the past month includes: ' || GROUP_CONCAT(WorkoutType || ' (' || SessionCount || ' sessions)', ', ') AS WorkoutVariety
FROM (
    SELECT WorkoutType, COUNT(*) AS SessionCount
    FROM Workouts
    WHERE UserID = ? AND Date BETWEEN date('now', '-30 days') AND date('now')
    GROUP BY WorkoutType
);





-- 9. Determine frequency of high-calorie meals
SELECT 'You have had ' || HighCalorieMealCount || ' high-calorie meals (over 700 calories) in the past month.' AS HighCalorieMealFrequency
FROM (
    SELECT COUNT(*) AS HighCalorieMealCount
    FROM FoodItems
    WHERE Calories > 700 AND NutritionLogID IN (SELECT NutritionLogID FROM NutritionLogs WHERE UserID = ?)
);

-- 10. Flag infrequent exercise patterns for a specific user
SELECT
  w.UserID,
  CASE
    WHEN w.WorkoutCount IS NULL OR w.WorkoutCount < 3 THEN
      'You have an infrequent exercise pattern with only ' || COALESCE(w.WorkoutCount, 0) || ' workouts in the last 14 days. Consider setting a regular workout schedule.'
    ELSE
      'Your workout frequency is fine with ' || w.WorkoutCount || ' workouts in the last 14 days.'
  END AS ExerciseAlert
FROM
  (SELECT UserID FROM Users WHERE UserID = ?) u
LEFT JOIN
  (SELECT UserID, COUNT(*) AS WorkoutCount
   FROM Workouts
   WHERE UserID = ? AND Date BETWEEN date('now', '-14 days') AND date('now')
   GROUP BY UserID) w
ON u.UserID = w.UserID;



-- 11. Assess adherence to recommended sleep cycles
SELECT 
  CASE 
    WHEN OptimalDates IS NULL THEN 'Your sleep cycles have been optimal in the last 30 days.'
    ELSE 'On the following dates, your sleep cycles were not optimal: ' || OptimalDates
  END AS SleepCycleAdjustmentAdvice
FROM (
  SELECT GROUP_CONCAT(DISTINCT sl.Date) AS OptimalDates
  FROM SleepLogs sl
  LEFT JOIN SleepCycles sc ON sl.SleepLogID = sc.SleepLogID
  WHERE sl.UserID = ? AND (sc.CycleType NOT LIKE 'Deep%' OR sc.CycleType IS NULL) AND sl.Date BETWEEN date('now', '-30 days') AND date('now')
);



-- 12. Review changes in blood pressure over time
SELECT 
  'On ' || Date || ', your blood pressure was: ' || BloodPressure || '.' AS BloodPressureReading
FROM HealthMetrics
WHERE UserID = ? AND Date BETWEEN date('now', '-90 days') AND date('now')
ORDER BY Date;



-- 13. Correlate exercise intensity with sleep quality
SELECT 
  'On ' || w.Date || ' you had a high-intensity workout with a sleep quality score of: ' || s.SleepQualityScore || '.'
FROM Workouts w
JOIN SleepLogs s ON w.UserID = s.UserID AND w.Date = s.Date
WHERE w.UserID = ? AND w.Intensity = 'High' AND w.Date BETWEEN date('now', '-30 days') AND date('now')
ORDER BY w.Date;



-- 14. Track micronutrient intake trends
SELECT 
  'Your micronutrient intake over the past month includes:' || char(10) ||
  'Vitamin A: ' || IFNULL(SUM(VitaminA), 'No data') || ' mcg' || char(10) ||
  'Vitamin C: ' || IFNULL(SUM(VitaminC), 'No data') || ' mg' || char(10) ||
  'Calcium: ' || IFNULL(SUM(Calcium), 'No data') || ' mg' || char(10) ||
  'Iron: ' || IFNULL(SUM(Iron), 'No data') || ' mg' as MicronutrientIntakeTrends
FROM FoodItems fi
JOIN NutritionLogs nl ON fi.NutritionLogID = nl.NutritionLogID
JOIN Micronutrients m ON fi.FoodItemID = m.FoodItemID
WHERE nl.UserID = ? AND nl.Date BETWEEN date('now', '-30 days') AND date('now');




-- 15. Recommendation for nutritional diversity with detailed feedback
SELECT 
  CASE
    WHEN UniqueFoodCount < 5 THEN 
      'Based on your last 30 days of food logs, you have consumed ' || UniqueFoodCount || 
      ' unique types of food. This suggests a lack of variety in your diet. A diverse diet includes fruits, vegetables, grains, proteins, and dairy. Consider incorporating more food groups into your meals for balanced nutrition.'
    ELSE 
      'Great job! You have consumed ' || UniqueFoodCount || 
      ' different types of food in the last 30 days, indicating a diverse diet. Keep up the good work and continue to explore a variety of food items.'
  END AS NutritionalDiversityRecommendation
FROM (
  SELECT COUNT(DISTINCT FoodName) AS UniqueFoodCount
  FROM FoodItems fi
  JOIN NutritionLogs nl ON fi.NutritionLogID = nl.NutritionLogID
  WHERE nl.UserID = ? AND nl.Date BETWEEN date('now', '-30 days') AND date('now')
);

-- 16. Assess mental well-being from workout notes
SELECT 
  CASE
    WHEN StressDates IS NOT NULL THEN 
      'Your workout notes have mentioned stress on the following dates: ' || StressDates
    ELSE 
      'No records of stress mentioned in your workout notes in the last 60 days.'
  END AS StressMentionedInNotes
FROM (
  SELECT GROUP_CONCAT(DetailedEntry, ' | ') AS StressDates
  FROM (
    SELECT Date || ': ' || Notes AS DetailedEntry
    FROM Workouts
    WHERE UserID = ? AND Notes LIKE '%stress%' AND Date BETWEEN date('now', '-60 days') AND date('now')
  )
);



-- 17. Provide a summary of the most recent health metrics changes over the past 6 months
WITH LatestMetrics AS (
  SELECT *
  FROM HealthMetrics
  WHERE UserID = ? AND Date BETWEEN date('now', '-180 days') AND date('now')
  ORDER BY Date DESC
  LIMIT 1
),
EarliestMetrics AS (
  SELECT *
  FROM HealthMetrics
  WHERE UserID = ? AND Date BETWEEN date('now', '-180 days') AND date('now')
  ORDER BY Date ASC
  LIMIT 1
)
SELECT 
  'Weight Change: ' || (LatestMetrics.Weight - EarliestMetrics.Weight) || ' kg' || char(10) ||
  'Body Fat Percentage Change: ' || (LatestMetrics.BodyFatPercentage - EarliestMetrics.BodyFatPercentage) || '%' || char(10) ||
  'Blood Pressure Change: ' || (LatestMetrics.BloodPressure) || ' (latest)' || char(10) ||
  'Glucose Level Change: ' || (LatestMetrics.GlucoseLevels - EarliestMetrics.GlucoseLevels) || ' mmol/L' || char(10) ||
  'Cholesterol Level Change: ' || (LatestMetrics.CholesterolLevels - EarliestMetrics.CholesterolLevels) || ' mg/dL'
FROM LatestMetrics, EarliestMetrics;



-- 18. Alert for irregular exercise patterns
SELECT 
  CASE 
    WHEN IrregularDates IS NOT NULL THEN 
      'You have had an irregular exercise pattern. On the following dates, you had multiple workouts: ' || IrregularDates || '. It is recommended to have at least one rest day between intense workouts.' 
    ELSE 
      'Your exercise pattern has been regular with no multiple workouts on the same day within the last 30 days.'
  END AS IrregularExercisePatternAlert
FROM (
  SELECT GROUP_CONCAT(Date || ' (' || WorkoutCount || ' workouts)', ', ') AS IrregularDates
  FROM (
    SELECT Date, COUNT(*) AS WorkoutCount
    FROM Workouts
    WHERE UserID = ? AND Date BETWEEN date('now', '-30 days') AND date('now')
    GROUP BY Date
    HAVING COUNT(*) > 1
  )
);

