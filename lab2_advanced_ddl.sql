SELECT current_user;
CREATE DATABASE university_main
    WITH OWNER = postgres
    TEMPLATE = template0
    ENCODING = 'UTF8';


CREATE DATABASE university_archive
    WITH CONNECTION LIMIT = 50
    TEMPLATE = template0;


CREATE DATABASE university_test
    WITH IS_TEMPLATE = true
    CONNECTION LIMIT = 10;


-- Task 1.2: Tablespace Operations
CREATE TABLESPACE student_data LOCATION '/data/students';


CREATE TABLESPACE course_data OWNER CURRENT_USER LOCATION '/data/courses';

CREATE DATABASE university_distributed
    WITH TABLESPACE = student_data
    TEMPLATE = template0
    ENCODING = 'LATIN9'
    LC_COLLATE = 'C'
    LC_CTYPE = 'C';


-- Part 2: Complex Table Creation
-- Task 2.1: University Management System
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone CHAR(15),
    date_of_birth DATE,
    enrollment_date DATE,
    gpa NUMERIC(3, 2),
    is_active BOOLEAN,
    graduation_year SMALLINT
);

CREATE TABLE professors (
    professor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    office_number VARCHAR(20),
    hire_date DATE,
    salary NUMERIC(12, 2),
    is_tenured BOOLEAN,
    years_experience INTEGER
);

CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_code CHAR(8),
    course_title VARCHAR(100),
    description TEXT,
    credits SMALLINT,
    max_enrollment INTEGER,
    course_fee NUMERIC(10, 2),
    is_online BOOLEAN,
    created_at TIMESTAMP WITHOUT TIME ZONE
);

-- Task 2.2: Time-based and Specialized Tables
CREATE TABLE class_schedule (
    schedule_id SERIAL PRIMARY KEY,
    course_id INTEGER,
    professor_id INTEGER,
    classroom VARCHAR(20),
    class_date DATE,
    start_time TIME WITHOUT TIME ZONE,
    end_time TIME WITHOUT TIME ZONE,
    duration INTERVAL
);

CREATE TABLE student_records (
    record_id SERIAL PRIMARY KEY,
    student_id INTEGER,
    course_id INTEGER,
    semester VARCHAR(20),
    year INTEGER,
    grade CHAR(2),
    attendance_percentage NUMERIC(4, 1),
    submission_timestamp TIMESTAMP WITH TIME ZONE,
    last_updated TIMESTAMP WITH TIME ZONE
);


-- Part 3: Advanced ALTER TABLE Operations
-- Task 3.1: Modifying Existing Tables
ALTER TABLE students
    ADD COLUMN middle_name VARCHAR(30),
    ADD COLUMN student_status VARCHAR(20),
    ALTER COLUMN phone TYPE VARCHAR(20),
    ALTER COLUMN student_status SET DEFAULT 'ACTIVE',
    ALTER COLUMN gpa SET DEFAULT 0.00;

ALTER TABLE professors
    ADD COLUMN department_code CHAR(5),
    ADD COLUMN research_area TEXT,
    ALTER COLUMN years_experience TYPE SMALLINT,
    ALTER COLUMN is_tenured SET DEFAULT false,
    ADD COLUMN last_promotion_date DATE;

ALTER TABLE courses
    ADD COLUMN prerequisite_course_id INTEGER,
    ADD COLUMN difficulty_level SMALLINT,
    ALTER COLUMN course_code TYPE VARCHAR(10),
    ALTER COLUMN credits SET DEFAULT 3,
    ADD COLUMN lab_required BOOLEAN DEFAULT false;

-- Task 3.2: Column Management Operations
ALTER TABLE class_schedule
    ADD COLUMN room_capacity INTEGER,
    DROP COLUMN duration,
    ADD COLUMN session_type VARCHAR(15),
    ALTER COLUMN classroom TYPE VARCHAR(30),
    ADD COLUMN equipment_needed TEXT;

ALTER TABLE student_records
    ADD COLUMN extra_credit_points NUMERIC(3, 1) DEFAULT 0.0,
    ALTER COLUMN grade TYPE VARCHAR(5),
    ADD COLUMN final_exam_date DATE,
    DROP COLUMN last_updated;

-- Part 4: Table Deletion Operations
-- Task 4.1: Single Table Drops
DROP TABLE IF EXISTS class_schedule;

-- Task 4.2: Conditional and Cascade Drops
DROP TABLE IF EXISTS student_records CASCADE;

-- Part 5: Database and Tablespace Cleanup
ALTER DATABASE university_test WITH IS_TEMPLATE = false;

-- Task 5.1 & 5.2: Deletion Operations
DROP DATABASE IF EXISTS university_test;
DROP DATABASE IF EXISTS university_archive;
DROP DATABASE IF EXISTS university_distributed;
DROP TABLESPACE IF EXISTS course_data;