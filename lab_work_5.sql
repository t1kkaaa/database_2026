-- Name: Elnara
-- Student ID: 25B031989

-- PART 1: CHECK Constraints

DROP TABLE IF EXISTS employees CASCADE;
CREATE TABLE employees (
    employee_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    age INTEGER CHECK (age BETWEEN 18 AND 65),
    salary NUMERIC CHECK (salary > 0)
);

INSERT INTO employees (employee_id, first_name, last_name, age, salary) VALUES
(1, 'Alizhan', 'Karimov', 25, 350000.00),
(2, 'Dilnaz', 'Sergazina', 42, 600000.50);

-- Failed attempt: age out of range (violates age CHECK)
-- INSERT INTO employees VALUES (3, 'Test', 'Testov', 17, 200000.00);

-- Failed attempt: salary less than or equal to zero (violates salary CHECK)
-- INSERT INTO employees VALUES (4, 'Test', 'Testov', 30, 0.00);


DROP TABLE IF EXISTS products_catalog CASCADE;
CREATE TABLE products_catalog (
    product_id INTEGER,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount CHECK (
        regular_price > 0 AND
        discount_price > 0 AND
        discount_price < regular_price
    )
);

INSERT INTO products_catalog VALUES
(1, 'Smartphone', 300000, 250000),
(2, 'Headphones', 50000, 45000);

-- Failed attempt: discount_price is greater than regular_price (violates valid_discount)
-- INSERT INTO products_catalog VALUES (3, 'Tablet', 100000, 120000);


DROP TABLE IF EXISTS bookings CASCADE;
CREATE TABLE bookings (
    booking_id INTEGER,
    check_in_date DATE,
    check_out_date DATE,
    num_guests INTEGER CHECK (num_guests BETWEEN 1 AND 10),
    CONSTRAINT chk_checkout_after_checkin CHECK (check_out_date > check_in_date)
);

INSERT INTO bookings VALUES
(1, '2026-11-01', '2026-11-05', 2),
(2, '2026-12-10', '2026-12-15', 4);

-- Failed attempt: check_out_date is earlier than check_in_date (violates chk_checkout_after_checkin)
-- INSERT INTO bookings VALUES (3, '2026-11-10', '2026-11-05', 2);


-- PART 2: NOT NULL Constraints

DROP TABLE IF EXISTS customers CASCADE;
CREATE TABLE customers (
    customer_id INTEGER NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

DROP TABLE IF EXISTS inventory CASCADE;
CREATE TABLE inventory (
    item_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);

INSERT INTO customers VALUES (1, 'test1@mail.kz', '+77011234567', '2026-01-10');
INSERT INTO customers VALUES (2, 'test2@mail.kz', NULL, '2026-01-11');

-- Failed attempt: inserting NULL into a NOT NULL column (email)
-- INSERT INTO customers VALUES (3, NULL, '+77019876543', '2026-01-12');


-- PART 3: UNIQUE Constraints

DROP TABLE IF EXISTS users CASCADE;
CREATE TABLE users (
    user_id INTEGER,
    username TEXT CONSTRAINT unique_username UNIQUE,
    email TEXT CONSTRAINT unique_email UNIQUE,
    created_at TIMESTAMP
);

INSERT INTO users VALUES (1, 'elnara_k', 'elnara@kbtu.kz', NOW());

-- Failed attempt: duplicate username (violates unique_username)
-- INSERT INTO users VALUES (2, 'elnara_k', 'other@kbtu.kz', NOW());


DROP TABLE IF EXISTS course_enrollments CASCADE;
CREATE TABLE course_enrollments (
    enrollment_id INTEGER,
    student_id INTEGER,
    course_code TEXT,
    semester TEXT,
    CONSTRAINT unique_student_course_sem UNIQUE (student_id, course_code, semester)
);

INSERT INTO course_enrollments VALUES (1, 101, 'CS102', 'Fall 2026');
-- Failed attempt to insert a duplicate combination of student_id, course_code, and semester
-- INSERT INTO course_enrollments VALUES (2, 101, 'CS102', 'Fall 2026');


-- PART 4: PRIMARY KEY Constraints

DROP TABLE IF EXISTS departments CASCADE;
CREATE TABLE departments (
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);

INSERT INTO departments VALUES
(1, 'IT and Programming', 'Building A'),
(2, 'Mathematical Analysis', 'Building B'),
(3, 'Economics and Management', 'Building C');

-- Failed attempt: inserting a duplicate primary key dept_id
-- INSERT INTO departments VALUES (1, 'Physics', 'Building D');

-- Failed attempt: inserting NULL into a primary key
-- INSERT INTO departments VALUES (NULL, 'Chemistry', 'Building E');


DROP TABLE IF EXISTS student_courses CASCADE;
CREATE TABLE student_courses (
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY (student_id, course_id)
);

/*
1. Difference between UNIQUE and PRIMARY KEY:
   - PRIMARY KEY uniquely identifies each row in a table, implicitly enforces NOT NULL, and only one PRIMARY KEY is allowed per table.
   - UNIQUE ensures that all values in a column(s) are different, allows a single NULL value (in standard SQL), and a table can have multiple UNIQUE constraints.
2. When to use a single-column vs. composite PRIMARY KEY:
   - A single-column PRIMARY KEY (e.g., ID) is used when the entity has a natural or artificial standalone identifier.
   - A composite PRIMARY KEY is used for associative (junction) tables (like student_courses), where uniqueness requires a combination of two or more columns.
3. Why a table can have only one PRIMARY KEY but multiple UNIQUE constraints:
   - The PRIMARY KEY defines the fundamental logical identifier for table rows (often tied to a clustered index), while UNIQUE constraints act as secondary integrity checks for alternative unique attributes.
*/


-- PART 5: FOREIGN KEY Constraints

DROP TABLE IF EXISTS employees_dept CASCADE;
CREATE TABLE employees_dept (
    emp_id INTEGER PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id),
    hire_date DATE
);

INSERT INTO employees_dept VALUES (1, 'Timur', 1, '2025-09-01');
-- Failed attempt: dept_id = 99 does not exist in the departments table
-- INSERT INTO employees_dept VALUES (2, 'Aigul', 99, '2025-09-02');


DROP TABLE IF EXISTS books CASCADE;
DROP TABLE IF EXISTS publishers CASCADE;
DROP TABLE IF EXISTS authors CASCADE;

CREATE TABLE authors (
    author_id INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);

CREATE TABLE publishers (
    publisher_id INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);

CREATE TABLE books (
    book_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES authors(author_id),
    publisher_id INTEGER REFERENCES publishers(publisher_id),
    publication_year INTEGER,
    isbn TEXT UNIQUE
);

INSERT INTO authors VALUES (1, 'Abai Kunanbayev', 'Kazakhstan');
INSERT INTO publishers VALUES (1, 'Mektep', 'Almaty');
INSERT INTO books VALUES (1, 'Book of Words', 1, 1, 1905, '978-601-00-0000-1');


DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products_fk CASCADE;
DROP TABLE IF EXISTS categories CASCADE;

CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE products_fk (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories(category_id) ON DELETE RESTRICT
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);

CREATE TABLE order_items (
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk(product_id),
    quantity INTEGER CHECK (quantity > 0)
);

INSERT INTO categories VALUES (1, 'Electronics');
INSERT INTO products_fk VALUES (101, 'Laptop', 1);
INSERT INTO orders VALUES (500, '2026-10-14');
INSERT INTO order_items VALUES (1001, 500, 101, 2);

-- 1. Attempt to delete a category that has associated products (fails due to RESTRICT):
-- DELETE FROM categories WHERE category_id = 1;

-- 2. Deleting an order automatically cascades and deletes related order items (CASCADE):
-- DELETE FROM orders WHERE order_id = 500;


-- PART 6: Practical Application (E-commerce Database Design)

DROP TABLE IF EXISTS ecommerce_order_details CASCADE;
DROP TABLE IF EXISTS ecommerce_orders CASCADE;
DROP TABLE IF EXISTS ecommerce_products CASCADE;
DROP TABLE IF EXISTS ecommerce_customers CASCADE;

CREATE TABLE ecommerce_customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

CREATE TABLE ecommerce_products (
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);

CREATE TABLE ecommerce_orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES ecommerce_customers(customer_id) ON DELETE CASCADE,
    order_date DATE NOT NULL,
    total_amount NUMERIC NOT NULL CHECK (total_amount >= 0),
    status TEXT NOT NULL CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled'))
);

CREATE TABLE ecommerce_order_details (
    order_detail_id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES ecommerce_orders(order_id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES ecommerce_products(product_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price >= 0)
);

INSERT INTO ecommerce_customers VALUES
(1, 'Madiyar', 'madiyar@gmail.com', '+77011111111', '2026-09-01'),
(2, 'Kamila', 'kamila@gmail.com', '+77022222222', '2026-09-02'),
(3, 'Arman', 'arman@gmail.com', '+77033333333', '2026-09-03'),
(4, 'Tomiris', 'tomiris@gmail.com', '+77044444444', '2026-09-04'),
(5, 'Damir', 'damir@gmail.com', '+77055555555', '2026-09-05');

INSERT INTO ecommerce_products VALUES
(101, 'Keyboard', 'Mechanical keyboard', 25000, 15),
(102, 'Mouse', 'Wireless mouse', 12000, 30),
(103, 'Monitor', '27 inch 144Hz', 110000, 5),
(104, 'Speaker', 'Bluetooth speaker', 18000, 20),
(105, 'Mousepad', 'Gaming mousepad', 4000, 50);

INSERT INTO ecommerce_orders VALUES
(1001, 1, '2026-10-01', 37000, 'delivered'),
(1002, 2, '2026-10-05', 110000, 'processing'),
(1003, 3, '2026-10-10', 18000, 'pending'),
(1004, 4, '2026-10-12', 4000, 'shipped'),
(1005, 5, '2026-10-13', 25000, 'cancelled');

INSERT INTO ecommerce_order_details VALUES
(1, 1001, 101, 1, 25000),
(2, 1001, 102, 1, 12000),
(3, 1002, 103, 1, 110000),
(4, 1003, 104, 1, 18000),
(5, 1005, 101, 1, 25000);

-- Test queries to verify constraint functionality:
-- Testing order status constraint (should fail because 'unknown' is not in the allowed list)
-- INSERT INTO ecommerce_orders VALUES (1006, 1, '2026-10-14', 5000, 'unknown');

-- Testing quantity > 0 constraint in order details (should fail):
-- INSERT INTO ecommerce_order_details VALUES (6, 1001, 102, 0, 12000);