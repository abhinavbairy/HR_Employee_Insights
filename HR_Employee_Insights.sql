-- HR Employee Data Insights – SQL + Power BI Project
-- Tools Used: Microsoft SQL Server (MSSQL), Power BI
--
-- Summary:
-- This project explores employee attrition, salary trends, and workplace patterns using SQL.
-- The goal is to uncover insights around who is leaving, how people are paid, and what factors influence employee satisfaction.
--
-- Core questions answered in this analysis:
-- - What is the overall attrition rate?
-- - Which departments and roles see the most turnover?
-- - How does salary vary by gender, education, and performance?
-- - What’s the average wait time for promotions?
-- - Do long-tenured employees earn more?
-- - How do commute distance, overtime, and work-life balance relate to attrition?
--
-- Power BI was used to build an interactive dashboard based on these query results.




-- Setup: Table structure checks
-- Basic checks to explore the structure of the EmployeeData table.
-- Helpful for understanding columns, data types, and any existing indexes.

-- List indexes on your EmployeeData table
Select Top 10*
From Hr.dbo.Employeedata;

-- Show column details for the EmployeeData table
EXEC sp_columns 'EmployeeData';



-- Salary & Performance Mismatches
-- Exploring employees who may be underpaid or overpaid based on their performance and tenure.
-- This helps identify potential fairness issues in compensation.

-- Needs a Raise: High Performers Getting Paid Less
Select EmployeeNumber,
JobRole,
PerformanceRating,
MonthlyIncome,
YearsAtCompany
From EmployeeData
Where PerformanceRating=4  
AND MonthlyIncome <=(Select Avg(MonthlyIncome) From EmployeeData)
AND Attrition = 0
Order By MonthlyIncome Asc;


-- Long Time in Company But Low Salery
Select EmployeeNumber,
Department,
JobRole,
YearsAtCompany,
MonthlyIncome 
From EmployeeData
Where YearsAtCompany >= 8 And MonthlyIncome < (Select Avg(MonthlyIncome) From EmployeeData)  AND Attrition = 1
Order By YearsAtCompany;	



-- Promotion Wait Time by Job Role
-- Checks how long, on average, employees in different roles wait for a promotion.
-- Useful for analyzing growth opportunities and internal mobility.

-- How long each job role waits for a promotion
Select JobRole,
Avg(YearsSinceLastPromotion) As Avg_Years_Since_Promotion
From EmployeeData
Group By JobRole
Order By Avg_Years_Since_Promotion;


-- Less Time in Company But High salary
Select EmployeeNumber,
Department, 
JobRole,
YearsAtCompany,
MonthlyIncome
From EmployeeData
Where YearsAtCompany <2 AND MonthlyIncome >= ( Select Avg(MonthlyIncome) From EmployeeData)
Order by YearsAtCompany;



-- Job Role Distribution
-- Finds the most common job roles within each department.
-- Helps understand team structure and role concentration.

-- Most common role in each department
Select Department,
JobRole,
Count(*)AS Role_count
From EmployeeData
Group By Department,JobRole
Order By Role_Count;



-- General Employee Metrics
-- Analyzes overall distribution of key employee-related metrics 
-- like performance rating, work-life balance, overtime, and training frequency.

--Employees by performance score
Select PerformanceRating,
Count(*) As Total_Employee
From EmployeeData
Group By PerformanceRating;


-- Distribution of work-life balance ratings
Select WorkLifeBalance,
Count(*) Total_Employee
From Employeedata
Group By WorkLifeBalance;


-- Overtime count: how many employees work extra hours
Select OverTime,
Count(*) As Total_Employee
From EmployeeData
Group By OverTime;


-- Distribution of training frequency across employees
Select TrainingTimesLastYear,
Count(*) As Total_Employee
From EmployeeData
Group By TrainingTimesLastYear;



--Employees Attrition Analysis
-- This section explores attrition across multiple dimensions:
-- age, gender, department, job level, education, and work-life factors.
-- Helps understand where employee turnover is highest and why.

-- Calculate overall attrition rate (1 = Yes, 0 = No)
Select
 COUNT(*) As Total_Employee,
 SUM(case when Attrition=1 Then 1 Else 0 END) As Employee_Left,
 Round(100.0*SUM(case when Attrition=1Then 1 Else 0 END)/Count(*), 2) As Attrition_Percentage
 From EmployeeData;


 -- Add age bands to see who’s leaving more
Select
Case
When Age Between 18AND 25 Then '18-25'
When Age Between 26 AND 35 Then '26-35'
When Age Between 36 And 45 Then '36-45'
When Age Between 46 And 60 Then '45-60'
 Else '60+'
 END As Age_Group,
Count(*) As Total_Employee,
Sum(case When ATtrition=1 Then 1 Else 0 END) As Employee_Left,
Round(100.0*Sum(case When Attrition = 1 Then 1 Else 0 End)/Count(*),2) As Attrition_Percentage
From EmployeeData
Group By 
Case
When Age Between 18AND 25 Then '18-25'
When Age Between 26 AND 35 Then '26-35'
When Age Between 36 And 45 Then '36-45'
When Age Between 46 And 60 Then '45-60'
 Else '60+'
 END
  Order By Age_Group;


-- Show attrition breakdown for each department
Select Department,
Count(*) As Total_Employee,
SUM(case When Attrition = 1 Then 1 Else 0 END) As Employee_Left,
Round(100.0 * Sum(case When Attrition = 1 Then 1 Else 0 END)/Count(*),2) As Attrition_Percentage
From EmployeeData
Group  by Department;


-- Show attrition statistics broken down by gender
Select Gender,
Count(*) As Total_Employee,
Sum(case When Attrition = 1 Then 1 Else 0 END)As Employee_Left,
Round(100.0 * SUM(case When Attrition = 1 Then 1 Else 0 END)/count(*),2) As Attrition_Percentage
From EmployeeData
Group By Gender;


-- Show attrition rate broken down by marital status
Select MaritalStatus,
Count(*) As Total_Employee,
Sum(case WHEN Attrition = 1 Then 1 Else 0 END) As Employee_Left,
Round(100.0 * SUM(case WHEN Attrition = 1 Then 1 Else 0 END)/Count(*),2) As Attrition_Percentage
From EmployeeData
Group By MaritalStatus;


-- Compare average commute distance for employees who left vs stayed
Select Attrition,
Count(*) As Total_Employee,
Avg(DistanceFromHome) As Distance_From_Home
From EmployeeData
Group By Attrition;


-- Show attrition rate by education field
Select EducationField,
Count(*) As Total_Employee,
Sum(case When ATtrition=1 Then 1 Else 0 END) As Employee_Left,
Round(100.0*Sum(case When Attrition = 1 Then 1 Else 0 End)/Count(*),2) As Attrition_Percentage
From EmployeeData
Group By EducationField
Order By Attrition_Percentage DESC;


-- Attrition rate by job level
Select JobLevel,
Count(*) As Total_Employee,
Sum(case When ATtrition=1 Then 1 Else 0 END) As Employee_Left,
Round(100.0*Sum(case When Attrition = 1 Then 1 Else 0 End)/Count(*),2) As Attrition_Percentage
From EmployeeData
Group By JobLevel
Order By Attrition_Percentage DESC;


-- Attrition By Worklife Balance 
Select WorkLifeBalance,
Count(*) As Total_Employee,
Sum(case When ATtrition=1 Then 1 Else 0 END) As Employee_Left,
Round(100.0*Sum(case When Attrition = 1 Then 1 Else 0 End)/Count(*),2) As Attrition_Percentage
From EmployeeData
Group By WorkLifeBalance
Order By Attrition_Percentage DESC;


-- Attrition rate by performance rating
Select PerformanceRating,
Count(*) As Total_Employee,
Sum(case When ATtrition=1 Then 1 Else 0 END) As Employee_Left,
Round(100.0*Sum(case When Attrition = 1 Then 1 Else 0 End)/Count(*),2) As Attrition_Percentage
From EmployeeData
Group By PerformanceRating
Order By Attrition_Percentage DESC;


-- Attrition rate by environment satisfaction score
Select EnvironmentSatisfaction,
Count(*) As Total_Employee,
Sum(case When ATtrition=1 Then 1 Else 0 END) As Employee_Left,
Round(100.0*Sum(case When Attrition = 1 Then 1 Else 0 End)/Count(*),2) As Attrition_Percentage
From EmployeeData
Group By EnvironmentSatisfaction
Order By Attrition_Percentage DESC;



-- Salary Analysis
-- Calculates average salaries across various categories like department, education field, gender, and job role.
-- Useful for identifying pay gaps or income trends.

-- Show overall average salary for all employees
Select 
Avg(MonthlyIncome) As AVG_Monthly_Salary
From EmployeeData;


-- Show average monthly income by department
Select Department,
Avg(MOnthlyIncome) As Avg_Monthly_Salary
From EmployeeData
Group By Department;


-- How salary changes with education level
Select EducationField,
Avg(MonthlyIncome) As Monthly_Salary
From EmployeeData
Group By EducationField;
 
 
-- Compare salary between genders
Select Gender,
Avg(MonthlyIncome) As Monthly_Salary
From EmployeeData
Group By Gender;



-- Tenure (how long someone has worked at the company) and Education Overview
-- Analyzes average years at the company by department and counts employees by education field.
-- Helps reveal experience levels and educational diversity across teams.

-- Show Average Years At Work per department
Select Department,
Count(*) As Total_Employee,
Avg(YearsAtCompany) As Years_At_Company
From EmployeeData
Group By Department;


-- Show average monthly salary for each job role
Select JobRole,
Avg(MonthlyIncome) As Monthly_Salary
From EmployeeData
Group By JobRole;


-- Count employees in each education field
Select EducationField,
Count(*) As Total_Employee
From EmployeeData
Group By EducationField;




-- ---------------------------------------------
-- End of SQL Analysis
--
-- This concludes the structured exploration of HR employee data.
-- The queries above were used to power visuals in a 6-page Power BI dashboard.
--
-- Key insights uncovered:
-- - Attrition is highest among younger age groups and varies across job roles
-- - High performers are not always paid the most
-- - Salary gaps exist based on gender and education fields
-- - Some roles wait longer for promotions or training
-- - Commute distance and work-life balance have strong links to attrition
--
-- For all visual summaries, refer to the Power BI dashboard.