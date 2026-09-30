CREATE DATABASE "advanced_lab";

DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;

CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    salary INTEGER DEFAULT 40000,
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(50),
    budget INTEGER,
    manager_id INTEGER
);

CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100),
    dept_id INTEGER,
    start_date DATE,
    end_date DATE,
    budget INTEGER
);

INSERT INTO employees (emp_id, first_name, last_name, department)
VALUES (DEFAULT, 'John', 'Doe', 'IT');

INSERT INTO employees (first_name, last_name, department, salary, status)
VALUES ('Alice', 'Smith', 'HR', DEFAULT, DEFAULT);

INSERT INTO departments (dept_name, budget, manager_id)
VALUES
    ('IT', 120000, 1),
    ('HR', 50000, 2),
    ('Sales', 90000, 3);

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Bob', 'Johnson', 'IT', 50000 * 1.1, CURRENT_DATE);

CREATE TEMP TABLE temp_employees AS
SELECT * FROM employees WHERE 1=0;

INSERT INTO temp_employees
SELECT * FROM employees
WHERE department = 'IT';


INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES
    ('Mark', 'Spencer', 'Sales', 45000, '2019-05-10', 'Active'),
    ('Elena', 'Rostova', 'Sales', 85000, '2018-03-15', 'Active'),
    ('Ivan', 'Petrov', 'IT', 35000, '2023-02-01', 'Inactive');

UPDATE employees
SET salary = salary * 1.10;

UPDATE employees
SET status = 'Senior'
WHERE salary > 60000 AND hire_date < '2020-01-01';

UPDATE employees
SET department = CASE
    WHEN salary > 80000 THEN 'Management'
    WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
    ELSE 'Junior'
END;

UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';

UPDATE departments d
SET budget = (
    SELECT AVG(salary) * 1.20
    FROM employees e
    WHERE e.department = d.dept_name
)
WHERE EXISTS (
    SELECT 1 FROM employees e WHERE e.department = d.dept_name
);

UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';

INSERT INTO projects (project_name, dept_id, start_date, end_date, budget)
VALUES ('Legacy System', 1, '2021-01-01', '2022-12-31', 30000);

DELETE FROM employees
WHERE status = 'Terminated';

DELETE FROM employees
WHERE salary < 40000 AND hire_date > '2023-01-01' AND department IS NULL;

DELETE FROM departments
WHERE dept_name NOT IN (
    SELECT DISTINCT department
    FROM employees
    WHERE department IS NOT NULL
);

DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;

INSERT INTO employees (first_name, last_name, department, salary)
VALUES ('NullUser', 'Test', NULL, NULL);

UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

DELETE FROM employees
WHERE salary IS NULL OR department IS NULL;

INSERT INTO employees (first_name, last_name, department, salary)
VALUES ('Michael', 'Scott', 'Sales', 65000)
RETURNING emp_id, first_name || ' ' || last_name AS full_name;

WITH old_data AS (
    SELECT emp_id, salary AS old_salary FROM employees WHERE department = 'IT'
)
UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT'
RETURNING emp_id,
          (SELECT old_salary FROM old_data WHERE old_data.emp_id = employees.emp_id) AS old_salary,
          salary AS new_salary;

DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;

INSERT INTO employees (first_name, last_name, department)
SELECT 'David', 'Miller', 'Finance'
WHERE NOT EXISTS (
    SELECT 1 FROM employees WHERE first_name = 'David' AND last_name = 'Miller'
);

UPDATE employees e
SET salary = CASE
    WHEN (SELECT budget FROM departments d WHERE d.dept_name = e.department) > 100000
        THEN salary * 1.10
    ELSE salary * 1.05
END
WHERE department IN (SELECT dept_name FROM departments);

WITH new_emps AS (
    INSERT INTO employees (first_name, last_name, salary, department)
    VALUES
        ('User1', 'Test', 30000, 'IT'),
        ('User2', 'Test', 32000, 'IT'),
        ('User3', 'Test', 34000, 'HR'),
        ('User4', 'Test', 36000, 'Sales'),
        ('User5', 'Test', 38000, 'Sales')
    RETURNING emp_id
)
UPDATE employees
SET salary = salary * 1.10
WHERE emp_id IN (SELECT emp_id FROM new_emps);

CREATE TABLE IF NOT EXISTS employee_archive (
    emp_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    salary INTEGER,
    hire_date DATE,
    status VARCHAR(20)
);

WITH moved_employees AS (
    DELETE FROM employees
    WHERE status = 'Inactive'
    RETURNING *
)
INSERT INTO employee_archive
SELECT * FROM moved_employees;

UPDATE projects
SET end_date = end_date + INTERVAL '30 days'
WHERE budget > 50000
  AND dept_id IN (
      SELECT d.dept_id
      FROM departments d
      JOIN employees e ON d.dept_name = e.department
      GROUP BY d.dept_id
      HAVING COUNT(e.emp_id) > 3
  );
