CREATE DATABASE Coursework1;
USE Coursework1;

-- Now i will create all necessary table first

CREATE TABLE Departments (
    department_name VARCHAR(50) PRIMARY KEY,
    building_location VARCHAR(50),
    annual_budget DECIMAL(12,2)
);

CREATE TABLE Instructors (
    instructorID VARCHAR(10) PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    annual_salary DECIMAL(10,2),
    department_name VARCHAR(50),
    FOREIGN KEY(department_name) REFERENCES Departments(department_name)
);


CREATE TABLE Classroom (
    building_name VARCHAR(50),
    room_no VARCHAR(10),
    capacity INT,
    PRIMARY KEY (building_name, room_no)
);


CREATE TABLE Courses (
    courseID VARCHAR(10) PRIMARY KEY,
    title VARCHAR(100),
    credit_value INT,
    department_name VARCHAR(50),
    FOREIGN KEY(department_name) REFERENCES Departments(department_name)
);



CREATE TABLE Sections (
    sectionID VARCHAR(10),
    courseID VARCHAR(10),
    semester VARCHAR(10),
    academic_year VARCHAR(10),
    course_offerings VARCHAR(20),
    building_name VARCHAR(50),
    room_no VARCHAR(10),
    PRIMARY KEY (sectionID, courseID,semester,academic_year),
    FOREIGN KEY(courseID) REFERENCES Courses(courseID),
    FOREIGN KEY(building_name, room_no) REFERENCES Classroom(building_name, room_no)
);

CREATE TABLE Teach (
    instructorID VARCHAR(10),
    sectionID VARCHAR(10),
    courseID VARCHAR(10),
    academic_year VARCHAR(10),
    semester VARCHAR(10),
    PRIMARY KEY (instructorID, sectionID, courseID, academic_year, semester),
    FOREIGN KEY(instructorID) REFERENCES Instructors(instructorID),
    FOREIGN KEY(sectionID, courseID,semester,academic_year) REFERENCES Sections(sectionID, courseID,semester,academic_year)
);


-- TASK 4a
CREATE TABLE Student (
    studentID VARCHAR(10) PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    academic_progress INT,
    department_name VARCHAR(50),
    FOREIGN KEY(department_name) REFERENCES Departments(department_name)
);

CREATE TABLE Takes (
    studentID VARCHAR(10),
    sectionID VARCHAR(10),
    courseID VARCHAR(10),
    academic_year VARCHAR(10),
    semester VARCHAR(10),
    PRIMARY KEY (studentID, sectionID, courseID, academic_year, semester),
    FOREIGN KEY(studentID) REFERENCES Student(studentID),
    FOREIGN KEY(sectionID, courseID,semester,academic_year) REFERENCES Sections(sectionID, courseID,semester,academic_year)
);
ALTER TABLE Takes
ADD COLUMN grade VARCHAR(5);

-- Task 4b
-- Some insert querys to have example data:

INSERT INTO Departments (department_name, building_location, annual_budget) VALUES
('Computer Science', 'Building A', 500000.00),
('Mathematics', 'Building B', 300000.00),
('Physics', 'Building C', 400000.00);

INSERT INTO Instructors (instructorID, first_name, last_name, annual_salary, department_name) VALUES
('I001', 'John', 'Peter', 60000.00, 'Computer Science'),
('I002', 'Bob', 'Johnson', 55000.00, 'Mathematics'),
('I003', 'Jack', 'Williams', 62000.00, 'Physics');

INSERT INTO Courses (courseID, title, credit_value, department_name) VALUES
('CS2123', 'Intro to CS', 15, 'Computer Science'),
('MATH201', 'Calculus', 15, 'Mathematics'),
('PHY301', 'Quantum Mechanics', 15, 'Physics');

INSERT INTO Classroom (building_name, room_no, capacity) VALUES
('Building A', '101', 500),
('Building B', '201', 400),
('Building C', '301', 350);


INSERT INTO Sections (sectionID, courseID, semester, academic_year, course_offerings, building_name, room_no) VALUES
('SEC01', 'CS2123', 'Fall', '2025', 'A', 'Building A', '101'),
('SEC02', 'MATH201', 'Spring', '2025', 'B', 'Building B', '201'),
('SEC03', 'PHY301', 'Fall', '2025', 'A', 'Building C', '301');

INSERT INTO Teach (instructorID, sectionID,courseID, semester, academic_year) VALUES
('I001', 'SEC01', 'CS2123', 'Fall', '2025'),
('I002', 'SEC02','MATH201', 'Spring', '2025');

-- now it shows the number of session taught

select Instructors.instructorID, Instructors.first_name,Instructors.last_name,
coalesce(count(takes.sectionID), 0) as sections_taught
From Instructors Instructors
left join teach takes
on Instructors.instructorID = takes.instructorID
group by Instructors.instructorID, Instructors.first_name, Instructors.last_name;

-- for task 4c we need to insert values in student and takes table
INSERT INTO Student (studentID, first_name, last_name, academic_progress, department_name) VALUES
('S001', 'Karan', 'Dhanota', 1, 'Computer Science'),
('S002', 'Nayan', 'Sorthi', 2, 'Mathematics'),
('S003', 'Swayam', 'Dabral', 3, 'Physics'),
('S004', 'Mahant', 'Lacximikant', 3, 'Computer Science');

-- this student will not be in Takes. so this student is just there
INSERT INTO Student (studentID, first_name, last_name, academic_progress, department_name) VALUES
('S005', 'Thomas', 'Patel', 1, 'Computer Science');

INSERT INTO Takes (studentID, sectionID, courseID, semester,academic_year, grade) VALUES
('S001', 'SEC01', 'CS2123', 'Fall', '2025', 'A'),
('S002', 'SEC02', 'MATH201', 'Spring', '2025', 'B'),
('S003', 'SEC03', 'PHY301', 'Fall', '2025', 'A'),
('S003', 'SEC01', 'CS2123', 'Fall', '2025', 'A'), -- student taking multiple session
('S003', 'SEC02', 'MATH201', 'Spring', '2025', 'B'), -- student taking multiple session
('S004', 'SEC02', 'MATH201', 'Spring', '2025', 'B');

-- actual task 4c a:
-- to test
-- select * from Student natural left outer join Takes;

-- 4a)
select Student.studentID, Student.department_name, Student.first_name, Student.last_name, Student.academic_progress, Takes.sectionID, Takes.courseID, Takes.academic_year, Takes.semester, Takes.grade
from Student Student, Takes Takes
where Student.studentID = Takes.studentID
union
select Student.studentID, Student.department_name, Student.first_name, Student.last_name, Student.academic_progress, null, null, null, null, null
from Student Student
where Student.studentID not in (select studentID from Takes);
/*List all students and their courses. */

-- Task 4c b
select Student.studentID, Student.department_name, Student.first_name, Student.last_name, Student.academic_progress, Takes.sectionID, Takes.courseID, Takes.academic_year, Takes.semester, Takes.grade
from Student
left join Takes on Student.studentID = Takes.studentID
union
select Student.studentID, Student.department_name, Student.first_name, Student.last_name, Student.academic_progress, Takes.sectionID, Takes.courseID, Takes.academic_year, Takes.semester, Takes.grade
from Student
right join Takes on Student.studentID = Takes.studentID
where Student.studentID is null;
/* Combine both left and right join to create a full outer join. */ 

-- Task 4d

-- for task d we need to have student with id=12345 that taskes several courses
-- we also need another table that stores the points for letter grade for eg A=4

CREATE TABLE grade_points (
    grade VARCHAR(5) PRIMARY KEY,
    points DECIMAL(3,2)
);

INSERT INTO grade_points (grade, points) VALUES
('A', 4.0),('A-', 3.7),('B+', 3.3),('B', 3.0),('B-', 2.7);

INSERT INTO Student (studentID, first_name, last_name, academic_progress, department_name) VALUES
('12345', 'Test', 'Student', 1, 'Computer Science');

INSERT INTO Takes (studentID, sectionID, courseID, semester,academic_year, grade) VALUES
('12345', 'SEC01', 'CS2123', 'Fall', '2025', 'A'),
('12345', 'SEC02', 'MATH201', 'Spring', '2025', 'B');

-- Task 4d i
select sum(Course.credit_value * Grade.points) as total_grades
from Takes Takes
join Courses Course on Takes.courseID = Course.courseID
join grade_points Grade on Takes.grade = Grade.grade
where Takes.studentID = '12345';
/* For student with ID 12345, calculates the grade as credits x points. */

-- Task 4d (ii)
select sum(Course.credit_value * Grade.points) / sum(Course.credit_value) as GPA
from Takes Takes
join Courses Course on Takes.courseID = Course.courseID
join grade_points Grade on Takes.grade = Grade.grade
where Takes.studentID = '12345';
/*Calculated GPA = total grades / total credits. */

-- task 4d (iii)
select Takes.studentID, sum(Course.credit_value * Grade.points) / sum(Course.credit_value) as GPA
from Takes Takes
join Courses Course on Takes.courseID = Course.courseID
join grade_points Grade on Takes.grade = Grade.grade
group by Takes.studentID;
/* Calculated GPA for every student.*/

-- Task 4e
create view Student_grades as
select Takes.studentID, sum(Course.credit_value * Grade.points) / sum(Course.credit_value) as GPA
from Takes Takes
join Courses Course on Takes.courseID = Course.courseID
left join grade_points Grade on Takes.grade = Grade.grade
group by Takes.studentID;

SELECT * FROM Student_Grades;
/* A view showing each student's GPA. */


