-- Create and use database
create database Schedule;
use Schedule;

--  Create Student table
create table Student_t
(NetID varchar(10) not null,
StudentFirstName varchar(30) not null,
StudentLastName varchar(30) not null,
Major varchar(30),
GraduationSemester Varchar(30),
GraduationYear integer,
constraint Student_PK primary key (NetID));

-- Create Course table
create table Course_t
(CourseID varchar(10) not null,
CourseName varchar(40) not null, 
CreditHours integer,
constraint Course_PK primary key (CourseID));

-- Create Instructor table
create table Instructor_t
(InstructorID varchar(10) not null,
InstructorFirstName varchar(30) not null,
InstructorLastName varchar(30) not null,
InstructorOffice varchar(20),
constraint Instructor_PK primary key (InstructorID));

-- Create Section table
create table Section_t
(SectionID varchar(20) not null,
CourseClassroom varchar(10) not null,
constraint Section_PK primary key (SectionID)); 

-- Create Book table
create table Book_t
(ISBN varchar(20) not null,
CourseBook varchar(100) not null,
CourseBookPublisher varchar(60), 
CourseID varchar(10) not null,
constraint Book_PK primary key (ISBN), 
constraint Book_FK1 foreign key (CourseID) references Course_t(CourseID));


-- Create Schedule table
create table Schedule_t
(NetID varchar(10) not null,
CourseID varchar(10) not null,
SectionID varchar(20) not null,
InstructorID varchar(10) not null,
CourseStartDate date,
CourseEndDate date,
constraint Schedule_PK primary key (NetID,CourseID),
constraint Schd_FK1 foreign key (NetID) references Student_t(NetID),
constraint Schd_FK2 foreign key (CourseID) references Course_t(CourseID),
constraint Schd_FK3 foreign key (SectionID) references Section_t(SectionID),
constraint Schd_FK4 foreign key (InstructorID) references Instructor_t(InstructorID)
);

-- Bulk Insert the table Student_t
BULK
INSERT Student_t
FROM 'D://CSU/Courses/610/Term_Paper/Student.csv'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO

-- Bulk Insert the table Course_t
BULK
INSERT Course_t
FROM 'D://CSU/Courses/610/Term_Paper/Course.csv'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO

-- Bulk Insert the table Instructor_t
BULK
INSERT Instructor_t
FROM 'D://CSU/Courses/610/Term_Paper/Instructor.csv'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO

-- Bulk Insert the table Book_t

BULK
INSERT Book_t
FROM 'D://CSU/Courses/610/Term_Paper/Book.csv'
WITH
(
FIELDTERMINATOR = '|',
ROWTERMINATOR = '\n'
)
GO
-- Bulk Insert the table Section_t

BULK
INSERT Section_t
FROM 'D://CSU/Courses/610/Term_Paper/Section.csv'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO


-- Bulk Insert the table Schedule_t

BULK
INSERT Schedule_t
FROM 'D://CSU/Courses/610/Term_Paper/Schedule.csv'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO


-- Query 1: Count the number of students who are graduating in the same semester.

select count(NetID) as 'Number of Students', Concat(GraduationSemester,GraduationYear) as Semester
from student_t
group by Concat(GraduationSemester,GraduationYear) ;

-- Query 2 : Display the students name and major who have taken BAN 610.

select Concat(StudentFirstName,StudentLastName) as 'Student Name', Major
from student_t where student_t.NetID in
(select Netid from schedule_t where courseID = 'BAN 610');

-- Query 3 : Display the NetID and student name of the students who have taken more than 3 courses in year 2019.

select NetID,concat(StudentFirstName,StudentLastName) as 'Student Name' from 
student_t where student_t.NetID in
(select NetID from
(
select NetID,count(courseID) from
schedule_t
where year(CourseStartDate) = 2019
group by NetID
having count(courseID) > 3) temp_t(NetID,Cnt));

-- Query 4 : Display the NetID and the total credit hours taken by each student in 2019

select NetID, sum(course_t.CreditHours) as 'Total Credit Hours'
from schedule_t,course_t
where schedule_t.CourseID = course_t.CourseID
and year(schedule_t.CourseStartDate) = 2019
group by NetID;

-- Query 5 : Display the instructors name and the number of course books prescribed by each instructor.

select concat(InstructorFirstName, InstructorLastName) as 'Instructor Name' ,
       count (distinct CourseBook) as 'Number of Course books'
from Instructor_t,  Book_t,  Schedule_t
where Schedule_t.CourseID=Book_t.CourseID
and Schedule_t.InstructorID = Instructor_t.InstructorID
group by InstructorFirstName, InstructorLastName;





