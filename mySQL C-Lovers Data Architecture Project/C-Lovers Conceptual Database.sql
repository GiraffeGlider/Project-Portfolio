#Authors: Jaiden Angeles & Tianci Qiao
#Date: April 5, 2023
#Assignment: Final Project - Field Exercise as a Database Architect for an On-Campus Business
#Topic: C-Lovers Fish & Chips Database

#Explanation: This is a database for the popular C-Lovers Fish & Chips chain, constructed based off real-life anlysis and questioning of the employees of Fish and Chips. For confidentiality or legal purposes, 
#sample data was used when inserting the data to operate the database and use queries.

SET NAMES utf8mb4;
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

DROP SCHEMA IF EXISTS C_Lovers ;
CREATE SCHEMA C_Lovers;
USE C_Lovers;

##################################################################################################################################################################################################
#Creating Tables
##################################################################################################################################################################################################

#Section 1: EMPLOYEE-RELATED***************************************************************************************************************************
-- Employees
CREATE TABLE employees (
  employee_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(255) NOT NULL,
  last_name VARCHAR(255) NOT NULL,
  date_of_birth DATE NOT NULL,
  hire_date DATE NOT NULL,
  termination_date DATE
);

-- Roles
CREATE TABLE roles (
  role_id INT AUTO_INCREMENT PRIMARY KEY,
  role_name VARCHAR(255) NOT NULL UNIQUE,
  hourly_rate DECIMAL(5, 2) NOT NULL
);

-- Employee Roles -- junction for roles and emloyees table
CREATE TABLE employee_roles (
  employee_id INT NOT NULL,
  role_id INT NOT NULL,
  PRIMARY KEY (employee_id, role_id),
  FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
  FOREIGN KEY (role_id) REFERENCES roles(role_id)
);

-- Shifts
CREATE TABLE shifts (
  shift_id INT AUTO_INCREMENT PRIMARY KEY,
  employee_id INT NOT NULL,
  shift_start DATETIME NOT NULL,
  shift_end DATETIME NOT NULL,
  hours_worked DECIMAL(5, 2) NOT NULL,
  date DATE NOT NULL,
  day_of_week VARCHAR(255) NOT NULL,
  FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- Clock In/Out
CREATE TABLE clock_in_out (
  clock_in_out_id INT AUTO_INCREMENT PRIMARY KEY,
  employee_id INT NOT NULL,
  clock_in DATETIME NOT NULL,
  clock_out DATETIME NOT NULL,
  date DATE NOT NULL,
  FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- Staff Absences
CREATE TABLE staff_absences (
  absence_id INT AUTO_INCREMENT PRIMARY KEY,
  employee_id INT NOT NULL,
  absence_date DATE NOT NULL,
  absence_reason VARCHAR(255),
  FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- Unavailable Days
CREATE TABLE unavailable_days (
  unavailable_id INT AUTO_INCREMENT PRIMARY KEY,
  employee_id INT NOT NULL,
  day_of_week VARCHAR(255) NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- Paychecks
CREATE TABLE paychecks (
  paycheck_id INT AUTO_INCREMENT PRIMARY KEY,
  employee_id INT NOT NULL,
  paycheck_date DATE NOT NULL,
  paycheck_amount DECIMAL(9, 2) NOT NULL,
  FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- Mentoring
CREATE TABLE mentoring (
	mentor_id INT NOT NULL,
	mentee_id INT NOT NULL,
	start_date DATE NOT NULL,
	end_date DATE NOT NULL,
	PRIMARY KEY (mentor_id, mentee_id),
	FOREIGN KEY (mentor_id) REFERENCES employees(employee_id),
	FOREIGN KEY (mentee_id) REFERENCES employees(employee_id)
);

-- Tips
CREATE TABLE tips (
  tip_id INT AUTO_INCREMENT PRIMARY KEY,
  employee_id INT NOT NULL,
  tip_amount DECIMAL(9, 2) NOT NULL,
  tip_date DATE NOT NULL,
  FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);


#Section 2: SUPPLIER-RELATED*******************************************************************************************************************************
-- Suppliers
CREATE TABLE suppliers (
   supplier_id INT AUTO_INCREMENT PRIMARY KEY,
   supplier_name VARCHAR(255) NOT NULL,
   supply_type VARCHAR(255) NOT NULL,
   storage_condition ENUM('frozen', 'refrigerated', 'room_temperature', 'other') NOT NULL,
   delivery_day ENUM('monday', 'other') NOT NULL,
   lead_time INT NOT NULL CHECK (lead_time >= 0),
   selected_supplier_id INT UNIQUE
);

-- Supplier contacts
CREATE TABLE supplier_contacts (
    contact_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT NOT NULL,
    contact_name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    email_address VARCHAR(255),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id) ON DELETE CASCADE,
    CONSTRAINT chk_contact_details CHECK (phone_number IS NOT NULL OR email_address IS NOT NULL)
);

-- Ingredients
CREATE TABLE ingredients (
  ingredient_id INT AUTO_INCREMENT PRIMARY KEY,
  ingredient_name VARCHAR(255) NOT NULL,
  ingredient_type ENUM('Produce', 'Proteins', 'Dairy', 'Baking and grains', 'Oils, condiments, and sauces', 'Seasonings and spices') NOT NULL,
  ingredient_used_in ENUM('menu_item', 'beverage') NOT NULL,
  selected_ingredient_id INT UNIQUE
);
 
 -- Ingredient alternatives -- junction of ingredients and special requests table. It's also a many to many recursive for ingredients and ingredient alternatives.
 CREATE TABLE ingredient_alternatives (
  alternative_id INT AUTO_INCREMENT PRIMARY KEY,
  original_ingredient_id INT NOT NULL,
  alternative_ingredient_id INT NOT NULL,
  FOREIGN KEY (original_ingredient_id) REFERENCES ingredients(ingredient_id),
  FOREIGN KEY (alternative_ingredient_id) REFERENCES ingredients(ingredient_id)
);

-- Menu Items
CREATE TABLE menu_items (
  menu_item_id INT AUTO_INCREMENT PRIMARY KEY,
  item_name VARCHAR(255) NOT NULL,
  category ENUM('appetizer', 'salad', 'dinner', 'burger', 'side', 'drink', 'take_out', 'add_on', 'beverage') NOT NULL,
  price DECIMAL(9, 2) NOT NULL,
  gluten_friendly BOOLEAN DEFAULT FALSE
);

-- Alternative Items
CREATE TABLE alternative_items (
  menu_item_id INT NOT NULL,
  alternative_item_id INT NOT NULL,
  PRIMARY KEY (menu_item_id, alternative_item_id),
  FOREIGN KEY (menu_item_id) REFERENCES menu_items(menu_item_id),
  FOREIGN KEY (alternative_item_id) REFERENCES menu_items(menu_item_id)
);

#INSERT INTO alternative_items (menu_item_id, alternative_item_id) VALUES (1, 2), (3, 4), (5, 6); #To suggest an alternative item for each menu item. Replace the number with each ID for the menu_items table.


-- Tables in restaurant
CREATE TABLE restaurant_tables (
  table_id INT AUTO_INCREMENT PRIMARY KEY,
  table_number INT NOT NULL,
  capacity INT NOT NULL
);

-- Menu Item Combinations (Recursive Many-to-Many Relationship)
CREATE TABLE menu_item_combinations (
  combo_id INT NOT NULL,
  menu_item_id INT NOT NULL,
  PRIMARY KEY (combo_id, menu_item_id),
  FOREIGN KEY (combo_id) REFERENCES menu_items(menu_item_id),
  FOREIGN KEY (menu_item_id) REFERENCES menu_items(menu_item_id)
);

-- Ingredients to Menu Items
CREATE TABLE ingredients_to_menu_items (
  ingredient_id INT NOT NULL,
  menu_item_id INT NOT NULL,
  ingredient_needed_per_order DECIMAL(9, 2) NOT NULL,
  PRIMARY KEY (ingredient_id, menu_item_id),
  FOREIGN KEY (ingredient_id) REFERENCES ingredients(ingredient_id),
  FOREIGN KEY (menu_item_id) REFERENCES menu_items(menu_item_id)
);

-- Menu Item Ingredients
CREATE TABLE menu_item_ingredients (
  menu_item_id INT NOT NULL,
  ingredient_id INT NOT NULL,
  PRIMARY KEY (menu_item_id, ingredient_id),
  FOREIGN KEY (menu_item_id) REFERENCES menu_items(menu_item_id),
  FOREIGN KEY (ingredient_id) REFERENCES ingredients(ingredient_id)
);

-- Food Inventory
CREATE TABLE food_inventory (
  inventory_id INT AUTO_INCREMENT PRIMARY KEY, -- will be generated automatically for each new record added to the food_inventory table
  ingredient_id INT NOT NULL,
  quantity DECIMAL(9, 2) NOT NULL,
  unit ENUM('kg', 'g', 'l', 'ml', 'count') NOT NULL,
  FOREIGN KEY (ingredient_id) REFERENCES ingredients(ingredient_id)
);

-- Stock Inventory
CREATE TABLE stock_inventory (
  stock_id INT AUTO_INCREMENT PRIMARY KEY,
  supplier_id INT NOT NULL,
  ingredient_id INT NOT NULL,
  quantity DECIMAL(9, 2) NOT NULL,
  unit ENUM('kg', 'g', 'l', 'ml', 'count') NOT NULL,
  FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id) ON DELETE CASCADE,
  FOREIGN KEY (ingredient_id) REFERENCES ingredients(ingredient_id)
);
ALTER TABLE stock_inventory
ADD COLUMN cost_per_unit DECIMAL(9, 2) NOT NULL;
-- Prepared Inventory
-- CREATE TABLE prepared_inventory (
-- prepared_id INT AUTO_INCREMENT PRIMARY KEY,
-- ingredient_id INT NOT NULL,
-- quantity DECIMAL(9, 2) NOT NULL,
-- unit ENUM('kg', 'g', 'l', 'ml', 'count') NOT NULL,
-- FOREIGN KEY (ingredient_id) REFERENCES ingredients(ingredient_id)
-- );

-- Replenishment History
CREATE TABLE replenishment_history (
  replenishment_id INT AUTO_INCREMENT PRIMARY KEY,
  supplier_id INT NOT NULL,
  ingredient_id INT NOT NULL,
  replenishment_date DATETIME NOT NULL,
  quantity DECIMAL(9, 2) NOT NULL,
  unit ENUM('kg', 'g', 'l', 'ml', 'count') NOT NULL,
  FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id) ON DELETE CASCADE,
  FOREIGN KEY (ingredient_id) REFERENCES ingredients(ingredient_id)
);

# Implement an index on the suppliers table for better query performance (example: when searching for a supplier by name)
CREATE INDEX idx_supplier_name ON suppliers(supplier_name);

#Section 3: ORDER-RELATED**************************************************************************************************************************************
-- Orders
CREATE TABLE orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  order_date DATE NOT NULL,
  order_time TIME NOT NULL,
  employee_id INT NOT NULL,
  table_id INT NOT NULL,
  FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
  FOREIGN KEY (table_id) REFERENCES restaurant_tables(table_id)
);

-- Order Items
CREATE TABLE order_items (
  order_item_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  menu_item_id INT NOT NULL,
  quantity INT NOT NULL,
  special_request_id INT,
  FOREIGN KEY (order_id) REFERENCES orders(order_id),
  FOREIGN KEY (menu_item_id) REFERENCES menu_items(menu_item_id),
  FOREIGN KEY (special_request_id) REFERENCES special_requests(special_request_id)
);

-- Special Requests
CREATE TABLE special_requests (
  special_request_id INT AUTO_INCREMENT PRIMARY KEY,
  request_type ENUM('light_batter', 'heavy_batter', 'no_fish', 'no_fries', 'allergy', 'other') NOT NULL,
  request_description VARCHAR(255),
  alternative_id INT,
  FOREIGN KEY (alternative_id) REFERENCES ingredient_alternatives(alternative_id)
);

# When a special request is made or a dietary restriction/allergy is noted, follow these steps:
	#1. Check the ingredient_alternatives table for possible alternatives to the ingredients that are part of the menu item.
	#2. If an alternative ingredient is found, add a record to the special_requests table with the alternative_id and order_item_id.
	#3. Ensure that the kitchen staff is aware of these changes and can prepare the meals accordingly.

INSERT INTO special_requests (request_description) VALUES ('Lightly Battered');
INSERT INTO special_requests (request_description) VALUES ('Heavily Battered'); ######More can be addeddd....
#In case of allergies, special requests can also be put in.

CREATE TABLE order_item_special_requests (
  order_item_id INT NOT NULL,
  special_request_id INT NOT NULL,
  PRIMARY KEY (order_item_id, special_request_id),
  FOREIGN KEY (order_item_id) REFERENCES order_items(order_item_id),
  FOREIGN KEY (special_request_id) REFERENCES special_requests(special_request_id)
);

-- Replacement Requests
CREATE TABLE replacement_requests (
  replacement_id INT AUTO_INCREMENT PRIMARY KEY,
  order_item_id INT NOT NULL,
  reason TEXT NOT NULL,
  status ENUM('pending', 'approved', 'rejected', 'completed') NOT NULL DEFAULT 'pending',
  FOREIGN KEY (order_item_id) REFERENCES order_items(order_item_id)
);
#FOR REPLACEMENT_REQUESTS....
#When customer sends back food, insert new record into 'replacement_requests' table with corresponding 'order_item id':
#INSERT INTO replacement_requests (order_item_id, reason) VALUES (5, 'Undercooked fish');

#How to update status of replacemnt request:
#UPDATE replacement_requests SET status = 'approved' WHERE replacement_id = 1;

#How to create new order item for approved replacement:
#INSERT INTO order_items (order_id, menu_item_id, quantity) VALUES (1, 2, 1);

-- Payments
CREATE TABLE payments (
  payment_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  payer_number INT NOT NULL,
  payment_method ENUM('cash', 'credit_card', 'gift_card') NOT NULL,
  amount DECIMAL(9, 2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Gift Cards
CREATE TABLE gift_cards (
  gift_card_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  card_code VARCHAR(20) NOT NULL,
  balance DECIMAL(9, 2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- All You Can Eat
CREATE TABLE all_you_can_eat (
  ayce_id INT AUTO_INCREMENT PRIMARY KEY,
  menu_item_id INT NOT NULL,
  price DECIMAL(6,2) NOT NULL,
  ayce_special_request_id INT,
  FOREIGN KEY (menu_item_id) REFERENCES menu_items(menu_item_id),
  FOREIGN KEY (ayce_special_request_id) REFERENCES ayce_special_requests(request_id)
);

CREATE TABLE ayce_special_requests (
  request_id INT AUTO_INCREMENT PRIMARY KEY,
  request_name VARCHAR(255) NOT NULL
);


-- INSERT INTO ayce_special_requests (request_name) VALUES ('only_fish'), ('only_fries'); #More can be added............

-- Coupons
CREATE TABLE coupons (
  coupon_id INT AUTO_INCREMENT PRIMARY KEY,
  coupon_code VARCHAR(20) NOT NULL,
  discount_type ENUM('percentage', 'fixed_amount') NOT NULL,
   discount_value DECIMAL(9, 2) NOT NULL,
  expiration_date DATE NOT NULL
);

-- Order Discounts
CREATE TABLE order_discounts (
  order_discount_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  coupon_id INT NOT NULL,
  discount_amount DECIMAL(9, 2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(order_id),
  FOREIGN KEY (coupon_id) REFERENCES coupons(coupon_id)
);

-- Refunds
CREATE TABLE refunds (
  refund_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  payment_id INT NOT NULL,
  refund_amount DECIMAL(9, 2) NOT NULL,
  refund_date DATE NOT NULL,
  reason TEXT NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(order_id),
  FOREIGN KEY (payment_id) REFERENCES payments(payment_id)
);

-- Reservations
CREATE TABLE reservations (
  reservation_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_name VARCHAR(255) NOT NULL,
  phone_number VARCHAR(15) NOT NULL,
  reservation_date DATE NOT NULL,
  reservation_time TIME NOT NULL,
  party_size INT NOT NULL,
  table_id INT NOT NULL,
  cancellation_status ENUM('active', 'cancelled') NOT NULL DEFAULT 'active',
  cancellation_date DATE,
  FOREIGN KEY (table_id) REFERENCES restaurant_tables(table_id)
);

#to Update inventory as food is being ordered
DELIMITER $$
CREATE TRIGGER order_items_insert_update
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
  UPDATE food_inventory AS fi
  JOIN ingredients_to_menu_items AS imi ON fi.ingredient_id = imi.ingredient_id -- Assuming you have a table linking ingredients and menu_items
  SET fi.quantity = fi.quantity - (NEW.quantity * imi.ingredient_needed_per_order)
  WHERE imi.menu_item_id = NEW.menu_item_id;
END $$
DELIMITER ;

##################################################################################################################################################################################################
-- Data Insert
##################################################################################################################################################################################################
-- Employees
INSERT INTO employees (first_name, last_name, date_of_birth, hire_date, termination_date) VALUES 
('Sarah', 'Johnson', '1992-08-12', '2020-06-01', NULL),
('David', 'Lee', '1988-04-21', '2019-09-05', '2023-03-30'),
('Maria', 'Garcia', '1994-02-28', '2021-01-15', NULL),
('Christopher', 'Nguyen', '1991-11-06', '2018-12-10', NULL),
('Emily', 'Chen', '1995-06-09', '2020-09-02', NULL),
('Michael', 'Jones', '1987-09-23', '2017-03-01', '2022-08-10'),
('Jessica', 'Kim', '1993-01-17', '2020-04-03', NULL),
('Anthony', 'Davis', '1989-03-11', '2019-05-20', '2022-12-15'),
('Megan', 'Wilson', '1990-12-28', '2018-10-01', NULL),
('Thomas', 'Brown', '1996-05-02', '2021-02-20', NULL);


-- Roles
INSERT INTO roles (role_id, role_name, hourly_rate) VALUES
(1, 'Manager', 30.00),
(2, 'Assistant manager', 25.00),
(3, 'Dishwasher', 12.00),
(4, 'Fryer', 12.00),
(5, 'Cashier', 10.00),
(6, 'Prep worker', 15.00),
(7, 'Waiter/Waitress', 8.00);



-- Employee Roles
INSERT INTO employee_roles (employee_id, role_id) VALUES 
-- Managers
(1, 1), -- Manager 1
(2, 1), -- Manager 2
(3, 1), -- Owner
-- Assistant Manager
(4, 2), -- Assistant Manager
-- Dishwashers
(5, 3), -- Dishwasher 1
(6, 3), -- Dishwasher 2
(7, 3), -- Dishwasher 3
-- Fryers
(8, 4), -- Fryer 1
(9, 4), -- Fryer 2
(10, 4), -- Fryer 3
-- Cashiers
(11, 5), -- Cashier 1
(12, 5), -- Cashier 2
(13, 5), -- Cashier 3
(14, 5), -- Cashier 4
(15, 5), -- Cashier 5
(16, 5), -- Cashier 6
-- Prep Worker
(17, 6), -- Prep Worker
-- Waiters/Waitresses
(18, 7), -- Waiter/Waitress 1
(19, 7), -- Waiter/Waitress 2
(20, 7), -- Waiter/Waitress 3
(21, 7), -- Waiter/Waitress 4
(22, 7), -- Waiter/Waitress 5
(23, 7), -- Waiter/Waitress 6
(24, 7), -- Waiter/Waitress 7
(25, 7); -- Waiter/Waitress 8


-- Shifts
INSERT INTO shifts (employee_id, shift_start, shift_end, hours_worked, date, day_of_week) VALUES
-- Prep work (8am to 11am) - 1 prep worker
(17, '2023-04-01 08:00:00', '2023-04-01 11:00:00', 3.00, '2023-04-01', 'Saturday'),
-- Morning shift (11am to 2pm) - 1 manager, 1 fry cook, 1 waitress, 1 cashier
(1, '2023-04-01 11:00:00', '2023-04-01 14:00:00', 3.00, '2023-04-01', 'Saturday'),
(4, '2023-04-01 11:00:00', '2023-04-01 14:00:00', 3.00, '2023-04-01', 'Saturday'),
(18, '2023-04-01 11:00:00', '2023-04-01 14:00:00', 3.00, '2023-04-01', 'Saturday'),
(11, '2023-04-01 11:00:00', '2023-04-01 14:00:00', 3.00, '2023-04-01', 'Saturday'),
-- Afternoon shift (2pm to 5pm) - 1 manager (same one), 1 fry cook (could be same), 2 waitress (usually different, 1 assistant manager or another manager, 2 cashiers
(1, '2023-04-01 14:00:00', '2023-04-01 17:00:00', 3.00, '2023-04-01', 'Saturday'),
(4, '2023-04-01 14:00:00', '2023-04-01 17:00:00', 3.00, '2023-04-01', 'Saturday'),
(9, '2023-04-01 14:00:00', '2023-04-01 17:00:00', 3.00, '2023-04-01', 'Saturday'),
(19, '2023-04-01 14:00:00', '2023-04-01 17:00:00', 3.00, '2023-04-01', 'Saturday'),
(20, '2023-04-01 14:00:00', '2023-04-01 17:00:00', 3.00, '2023-04-01', 'Saturday'),
(12, '2023-04-01 14:00:00', '2023-04-01 17:00:00', 3.00, '2023-04-01', 'Saturday'),
(21, '2023-04-01 14:00:00', '2023-04-01 17:00:00', 3.00, '2023-04-01', 'Saturday'),
(22, '2023-04-01 14:00:00', '2023-04-01 17:00:00', 3.00, '2023-04-01', 'Saturday'),
-- Evening shift (5pm to 8:30 pm)
(6, '2023-04-01 17:00:00', '2023-04-01 20:30:00', 3.50, '2023-04-01', 'Saturday'),
(1, '2023-04-01 17:00:00', '2023-04-01 20:30:00', 3.50, '2023-04-01', 'Saturday'),
(2, '2023-04-01 17:00:00', '2023-04-01 20:30:00', 3.50, '2023-04-01', 'Saturday'),
(8, '2023-04-01 17:00:00', '2023-04-01 20:30:00', 3.50, '2023-04-01', 'Saturday'),
(10, '2023-04-01 17:00:00', '2023-04-01 20:30:00', 3.50, '2023-04-01', 'Saturday'),
(11, '2023-04-01 17:00:00', '2023-04-01 20:30:00', 3.50, '2023-04-01', 'Saturday'),
(12, '2023-04-01 17:00:00', '2023-04-01 20:30:00', 3.50, '2023-04-01', 'Saturday'),
(13, '2023-04-01 17:00:00', '2023-04-01 20:30:00', 3.50, '2023-04-01', 'Saturday'),
-- Evening shift (5pm to 9:30 pm friday)
(5, '2023-04-01 17:00:00', '2023-04-01 21:30:00', 4.50, '2023-04-01', 'Friday'),
(1, '2023-04-01 17:00:00', '2023-04-01 21:30:00', 4.50, '2023-04-01', 'Friday'),
(2, '2023-04-01 17:00:00', '2023-04-01 21:30:00', 4.50, '2023-04-01', 'Friday'),
(8, '2023-04-01 17:00:00', '2023-04-01 21:30:00', 4.50, '2023-04-01', 'Friday'),
(10, '2023-04-01 17:00:00', '2023-04-01 21:30:00', 4.50, '2023-04-01', 'Friday'),
(11, '2023-04-01 17:00:00', '2023-04-01 21:30:00', 4.50, '2023-04-01', 'Friday'),
(12, '2023-04-01 17:00:00', '2023-04-01 21:30:00', 4.50, '2023-04-01', 'Friday'),
(13, '2023-04-01 17:00:00', '2023-04-01 21:30:00', 4.50, '2023-04-01', 'Friday'),
(14, '2023-04-01 17:00:00', '2023-04-01 21:30:00', 4.50, '2023-04-01', 'Friday'),
(15, '2023-04-01 17:00:00', '2023-04-01 21:30:00', 4.50, '2023-04-01', 'Friday');

-- Clock In/Out
INSERT INTO clock_in_out (employee_id, clock_in, clock_out, date) VALUES
(1, '2023-04-03 08:30:00', '2023-04-03 16:30:00', '2023-04-03'),
(2, '2023-04-03 09:00:00', '2023-04-03 17:00:00', '2023-04-03'),
(3, '2023-04-03 10:00:00', '2023-04-03 17:30:00', '2023-04-03'),
(4, '2023-04-03 11:00:00', '2023-04-03 18:00:00', '2023-04-03'),
(5, '2023-04-03 12:00:00', '2023-04-03 20:00:00', '2023-04-03'),
(6, '2023-04-03 12:30:00', '2023-04-03 21:00:00', '2023-04-03'),
(7, '2023-04-03 13:00:00', '2023-04-03 21:30:00', '2023-04-03'),
(8, '2023-04-03 14:00:00', '2023-04-03 22:00:00', '2023-04-03'),
(9, '2023-04-03 15:00:00', '2023-04-03 22:30:00', '2023-04-03'),
(10, '2023-04-03 16:00:00', '2023-04-03 23:00:00', '2023-04-03');


-- Staff Absences
INSERT INTO staff_absences (employee_id, absence_date, absence_reason) VALUES
(2, '2023-04-01', 'Sick'),
(3, '2023-04-02', 'Family emergency'),
(5, '2023-04-03', 'Vacation'),
(6, '2023-04-01', 'Doctor appointment'),
(7, '2023-04-02', 'Personal day'),
(9, '2023-04-03', 'Bereavement leave');


-- Unavailable Days
INSERT INTO unavailable_days (employee_id, day_of_week, start_time, end_time) VALUES
(1, 'Monday', '09:00:00', '13:00:00'),
(2, 'Tuesday', '14:00:00', '18:00:00'),
(3, 'Wednesday', '11:00:00', '15:00:00'),
(4, 'Thursday', '08:00:00', '12:00:00'),
(6, 'Friday', '12:00:00', '16:00:00'),
(7, 'Saturday', '17:00:00', '21:00:00'),
(9, 'Sunday', '13:00:00', '17:00:00');

-- Paychecks
INSERT INTO paychecks (employee_id, paycheck_date, paycheck_amount) VALUES
(1, '2023-04-01', 1200.00),
(2, '2023-04-01', 1300.00),
(3, '2023-04-01', 1100.00),
(4, '2023-04-01', 1400.00),
(5, '2023-04-01', 1500.00),
(6, '2023-04-01', 1000.00),
(7, '2023-04-01', 1100.00),
(8, '2023-04-01', 1200.00),
(9, '2023-04-01', 1300.00),
(10, '2023-04-01', 1400.00);

-- Mentoring --  It's a many to many recursive for employees and mentoring tables.
INSERT INTO mentoring (mentor_id, mentee_id, start_date, end_date) VALUES
	(1, 2, '2023-01-01', '2023-03-31'),
	(1, 3, '2023-02-01', '2023-04-30'),
	(2, 4, '2023-03-01', '2023-05-31'),
	(3, 5, '2023-04-01', '2023-06-30'),
	(4, 6, '2023-05-01', '2023-07-31'),
	(4, 7, '2023-06-01', '2023-08-31'),
	(5, 8, '2023-07-01', '2023-09-30'),
	(6, 9, '2023-08-01', '2023-10-31'),
	(7, 10, '2023-09-01', '2023-11-30');


-- Tips
INSERT INTO tips (employee_id, tip_amount, tip_date) VALUES
(1, 20.00, '2023-04-01'),
(2, 30.00, '2023-04-01'),
(3, 15.00, '2023-04-01'),
(4, 25.00, '2023-04-01'),
(5, 35.00, '2023-04-01'),
(6, 10.00, '2023-04-01'),
(7, 20.00, '2023-04-01'),
(8, 15.00, '2023-04-01'),
(9, 30.00, '2023-04-01'),
(10, 25.00, '2023-04-01');



#SUPPLIER-RELATED*******************************************************************************************************************************
-- Suppliers
INSERT INTO suppliers (supplier_name, supply_type, storage_condition, delivery_day, lead_time) VALUES
('Good Oils', 'beef_tallow_fat', 'room_temperature', 'monday', 2),
('Ocean Delight', 'halibut', 'frozen', 'other', 3),
('Seafood Express', 'cod', 'refrigerated', 'other', 1),
('Pacific Fresh', 'salmon', 'refrigerated', 'monday', 2),
('Northwest Catch', 'haddock', 'frozen', 'other', 4),
('Oyster Bay', 'oyster', 'refrigerated', 'monday', 3),
('Onion King', 'onion', 'room_temperature', 'other', 1),
('Dill Pickle Inc.', 'dill_pickle', 'refrigerated', 'monday', 2),
('Prawn Haven', 'prawn', 'frozen', 'other', 3),
('Chicken Supreme', 'chicken_strip', 'frozen', 'monday', 1),
('Coleslaw Co.', 'coleslaw', 'refrigerated', 'other', 2),
('Caesar Salad Inc.', 'caesar_salad', 'refrigerated', 'monday', 1),
('C-Dog Corporation', 'c_dog', 'frozen', 'monday', 3),
('Beverage Co.', 'drink', 'room_temperature', 'other', 1),
('Mushroom Kingdom', 'mushroom', 'refrigerated', 'monday', 4);
UPDATE suppliers
SET selected_supplier_id = CASE supplier_name
     WHEN 'Good Oils' THEN 1
     WHEN 'Ocean Delight' THEN 2
     WHEN 'Seafood Express' THEN 3
     WHEN 'Pacific Fresh' THEN 4
     WHEN 'Northwest Catch' THEN 5
     WHEN 'Oyster Bay' THEN 6
     WHEN 'Onion King' THEN 7
     WHEN 'Dill Pickle Inc.' THEN 8
     WHEN 'Prawn Haven' THEN 9
     WHEN 'Chicken Supreme' THEN 10
     WHEN 'Coleslaw Co.' THEN 11
     WHEN 'Caesar Salad Inc.' THEN 12
     WHEN 'C-Dog Corporation' THEN 13
     WHEN 'Beverage Co.' THEN 14
     WHEN 'Mushroom Kingdom' THEN 15
 END
WHERE supplier_id > 0;



-- Supplier contacts
INSERT INTO supplier_contacts (supplier_id, contact_name, phone_number, email_address) VALUES
(1, 'John Smith', NULL, 'john@goodoils.com'),
(2, 'Jane Doe', '555-555-5555', 'jane@oceandelight.com'),
(3, 'Bob Johnson', '444-444-4444', 'bob@seafoodexpress.com'),
(4, 'Sarah Lee', '555-123-4567', 'sarah@pacificfresh.com'),
(1, 'Mike Jones', '777-777-7777', 'mike@goodoils.com'),
(2, 'Emily Davis', '111-111-1111', 'emily@oceandelight.com'),
(3, 'David Brown', NULL, 'david@seafoodexpress.com'),
(4, 'Rachel Green', '333-333-3333', 'rachel@pacificfresh.com'),
(1, 'Tom Wilson', '222-222-2222', 'tom@goodoils.com'),
(2, 'Chris Carter', '888-888-8888', 'chris@oceandelight.com'),
(3, 'Linda Nguyen', '444-123-4567', 'linda@seafoodexpress.com'),
(4, 'Mark Lee', '222-444-5555', 'mark@pacificfresh.com'),
(1, 'Mike Chen', '666-666-6666', 'mike@goodoils.com'),
(2, 'Lisa Kim', NULL, 'lisa@oceandelight.com'),
(3, 'Steve Lee', '777-444-3333', 'steve@seafoodexpress.com'),
(4, 'John Doe', '555-123-7890', 'john@pacificfresh.com');


-- Ingredients
INSERT INTO ingredients (ingredient_name, ingredient_type, ingredient_used_in) VALUES
('Onions', 'Produce', 'menu_item'),
('Dill pickles', 'Produce', 'menu_item'),
('Romaine lettuce', 'Produce', 'menu_item'),
('Cabbage', 'Produce', 'menu_item'),
('Carrots', 'Produce', 'menu_item'),
('Potatoes', 'Produce', 'menu_item'),
('Lemons', 'Produce', 'beverage'),
('Vegetables (for chowder)', 'Produce', 'menu_item'),
('Garlic', 'Produce', 'menu_item'),
('Cod', 'Proteins', 'menu_item'),
('Haddock', 'Proteins', 'menu_item'),
('Halibut', 'Proteins', 'menu_item'),
('Salmon', 'Proteins', 'menu_item'),
('Shrimp', 'Proteins', 'menu_item'),
('Chicken', 'Proteins', 'menu_item'),
('Oysters', 'Proteins', 'menu_item'),
('Prawns', 'Proteins', 'menu_item'),
('Bacon (for chowder)', 'Proteins', 'menu_item'),
('Butter', 'Dairy', 'menu_item'),
('Mayonnaise', 'Dairy', 'menu_item'),
('Parmesan cheese', 'Dairy', 'menu_item'),
('Milk', 'Dairy', 'beverage'),
('Chocolate milk', 'Dairy', 'beverage'),
('All-purpose flour (for batter and coating)', 'Baking and grains', 'menu_item'),
('Baking powder', 'Baking and grains', 'menu_item'),
('Bread crumbs', 'Baking and grains', 'menu_item'),
('Buns', 'Baking and grains', 'menu_item'),
('Croutons', 'Baking and grains', 'menu_item'),
('Cooking oil', 'Oils, condiments, and sauces', 'menu_item'),
('Beef tallow', 'Oils, condiments, and sauces', 'menu_item'),
('Tartar sauce', 'Oils, condiments, and sauces', 'menu_item'),
('Caesar salad dressing', 'Oils, condiments, and sauces', 'menu_item'),
('Malt vinegar', 'Oils, condiments, and sauces', 'menu_item'),
('Ketchup', 'Oils, condiments, and sauces', 'menu_item'),
('Mustard', 'Oils, condiments, and sauces', 'menu_item'),
('Gravy', 'Oils, condiments, and sauces', 'menu_item'),
('Relish', 'Oils, condiments, and sauces', 'menu_item'),
('Hot sauce', 'Oils, condiments, and sauces', 'menu_item'),
('Salt', 'Seasonings and spices', 'menu_item'),
('Pepper', 'Seasonings and spices', 'menu_item'),
('Cayenne', 'Seasonings and spices', 'menu_item'),
('Seasonings (for chowder and other dishes)', 'Seasonings and spices', 'menu_item'),
('Dill', 'Seasonings and spices', 'menu_item');
UPDATE ingredients
SET selected_ingredient_id = CASE ingredient_name
  WHEN 'Onions' THEN 1
  WHEN 'Dill pickles' THEN 2
   WHEN 'Romaine lettuce' THEN 3
   WHEN 'Cabbage' THEN 4
   WHEN 'Carrots' THEN 5
   WHEN 'Potatoes' THEN 6
   WHEN 'Lemons' THEN 7
   WHEN 'Vegetables (for chowder)' THEN 8
   WHEN 'Garlic' THEN 9
   WHEN 'Cod' THEN 10
   WHEN 'Haddock' THEN 11
   WHEN 'Halibut' THEN 12
   WHEN 'Salmon' THEN 13
   WHEN 'Shrimp' THEN 14
   WHEN 'Chicken' THEN 15
   WHEN 'Oysters' THEN 16
   WHEN 'Prawns' THEN 17
   WHEN 'Bacon (for chowder)' THEN 18
   WHEN 'Butter' THEN 19
   WHEN 'Mayonnaise' THEN 20
   WHEN 'Parmesan cheese' THEN 21
   WHEN 'Milk' THEN 22
   WHEN 'Chocolate milk' THEN 23
   WHEN 'All-purpose flour (for batter and coating)' THEN 24
   WHEN 'Baking powder' THEN 25
   WHEN 'Bread crumbs' THEN 26
   WHEN 'Buns' THEN 27
   WHEN 'Croutons' THEN 28
   WHEN 'Cooking oil' THEN 29
   WHEN 'Beef tallow' THEN 30
   WHEN 'Tartar sauce' THEN 31
   WHEN 'Caesar salad dressing' THEN 32
   WHEN 'Malt vinegar' THEN 33
   WHEN 'Ketchup' THEN 34
   WHEN 'Mustard' THEN 35
   WHEN 'Gravy' THEN 36
   WHEN 'Relish' THEN 37
   WHEN 'Hot sauce' THEN 38
   WHEN 'Salt' THEN 39
   WHEN 'Pepper' THEN 40
   WHEN 'Cayenne' THEN 41
   WHEN 'Seasonings (for chowder and other dishes)' THEN 42
   WHEN 'Dill' THEN 43
END
WHERE ingredient_id > 0;




 -- Ingredient alternatives 
INSERT INTO ingredient_alternatives (original_ingredient_id, alternative_ingredient_id) VALUES
((SELECT ingredient_id FROM ingredients WHERE ingredient_name = 'Bread crumbs'), (SELECT ingredient_id FROM ingredients WHERE ingredient_name = 'Seasonings (for chowder and other dishes)')),
((SELECT ingredient_id FROM ingredients WHERE ingredient_name = 'Cooking oil'), (SELECT ingredient_id FROM ingredients WHERE ingredient_name = 'Beef tallow'));


-- Menu Items
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (1, 'Onion Rings (Full Order)', 'appetizer', 10.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (2, 'Onion Rings (Half Order)', 'appetizer', 5.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (3, 'Deep Fried Dill Pickles', 'appetizer', 9.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (4, 'Popcorn Shrimp', 'appetizer', 10.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (5, 'Battered Mushrooms', 'appetizer', 10.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (6, 'Prawns', 'appetizer', 12.49);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (7, 'Small C-FOOD CHOWDER', 'salad', 5.49);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (8, 'Large C-FOOD CHOWDER', 'salad', 7.49);
INSERT INTO menu_items (menu_item_id, item_name, category, price, gluten_friendly) VALUES (9, 'Small Caesar Salad', 'salad', 7.99, TRUE);
INSERT INTO menu_items (menu_item_id, item_name, category, price, gluten_friendly) VALUES (10, 'Large Caesar Salad', 'salad', 10.99, TRUE);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (11, 'Okanagan Spring Pale Ale (Sleeve)', 'drink', 6.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (12, 'Okanagan Spring 1516 Lager (Sleeve)', 'drink', 6.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (13, 'Okanagan Spring Pale Ale (Pitcher)', 'drink', 19.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (14, 'Okanagan Spring 1516 Lager (Pitcher)', 'drink', 19.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (15, 'Chardonnay (Glass)', 'drink', 6.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (16, 'Cab Merlot (Glass)', 'drink', 6.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (17, 'Pinot Grigio (Glass)', 'drink', 6.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (18, 'Shiraz (Glass)', 'drink', 6.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (19, 'Chardonnay (½ liter)', 'drink', 15.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (20, 'Cab Merlot (½ liter)', 'drink', 15.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (21, 'Pinot Grigio (½ liter)', 'drink', 15.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (22, 'Shiraz (½ liter)', 'drink', 15.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (23, 'Chardonnay (1 liter)', 'drink', 22.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (24, 'Cab Merlot (1 liter)', 'drink', 22);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (25, 'Pinot Grigio (1 liter)', 'drink', 22.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (26, 'Shiraz (1 liter)', 'drink', 22.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (27, 'Hot Chocolate', 'drink', 2.49);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (28, 'Coffee', 'drink', 2.49);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (29, 'Tea', 'drink', 2.49);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (30, 'Milk (small)', 'drink', 1.79);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (31, 'Chocolate Milk (small)', 'drink', 1.89);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (32, 'Soft Drinks (small)', 'drink', 1.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (33, 'Apple Juice (small)', 'drink', 1.89);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (34, 'Orange Juice (small)', 'drink', 1.89);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (35, 'Tomato Juice', 'drink', 1.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (36, 'Milk (large)', 'drink', 2.39);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (37, 'Chocolate Milk (large)', 'drink', 2.49);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (38, 'Soft Drinks (bottomless)', 'drink', 3.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (39, 'Apple Juice (large)', 'drink', 2.39);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (40, 'Orange Juice (large)', 'drink', 2.39);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (41, 'Domestic Bottled Beer - Molson Canadian', 'drink', 6.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (42, 'Domestic Bottled Beer - Coors Light', 'drink', 6.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (43, 'Domestic Bottled Beer - Budweiser', 'drink', 6.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (44, 'Domestic Bottled Beer - Kokanee', 'drink', 6.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (45, 'Imported Bottled Beer - Corona', 'drink', 7.49);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (46, 'Imported Bottled Beer - Miller Genuine Draft', 'drink', 7.49);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (47, 'Imported Bottled Beer - Guinness Pub Draught', 'drink', 7.49);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (48, 'Imported Bottled Beer - Newcastle Brown Ale', 'drink', 7.49);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (49, 'Imported Bottled Beer - Stella Artois', 'drink', 7.49);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (50, 'Coolers & Ciders - Hard Lemonade', 'drink', 7.49);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (51, 'Coolers & Ciders - Cider', 'drink', 7.49);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (52, 'Craft Beer - Steamworks Flagship IPA', 'drink', 7.49);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (53, 'Craft Beer - Steamworks Pale Ale', 'drink', 7.49);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (54, 'Craft Beer - Steamworks Pilsner', 'drink', 7.49);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (55, 'O’Doul’s Non-alcoholic', 'drink', 3.49);

-- Enhance your meal with a C-Lovers Add-on
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (56, 'Prawns', 'add_on', 3.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (57, 'Deep Fried Pickles', 'add_on', 3.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (58, 'Onion Rings', 'add_on', 3.99);

-- Dinner
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (59, 'C-Lovers Platter', 'dinner', 26.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (60, 'The Ultimate Platter Dinner For 2', 'dinner', 34.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (61, 'Cod Dinner 1 Pc', 'dinner', 14.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (62, 'Cod Dinner 2 Pc', 'dinner', 22.49);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (63, 'Haddock Dinner 1 Pc', 'dinner', 15.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (64, 'Haddock Dinner 2 Pc', 'dinner', 23.49);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (65, 'Halibut Dinner 1 Pc', 'dinner', 19.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (66, 'Halibut Dinner 2 Pc', 'dinner', 30.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (67, 'Salmon Dinner 1 Pc', 'dinner', 15.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (68, 'Salmon Dinner 2 Pc', 'dinner', 23.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (69, 'Prawn Dinner', 'dinner', 19.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (70, 'Halibut Platter', 'dinner', 26.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (71, 'Cod Platter', 'dinner', 22.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (72, 'Chicken Strips', 'dinner', 16.49);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (73, 'Oyster Dinner', 'dinner', 26.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (74, 'Haddock Platter', 'dinner', 23.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (75, 'Salmon Platter', 'dinner', 23.99);

-- Burgers
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (76, 'Salmon Burger', 'burger', 9.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (77, 'Haddock Burger', 'burger', 9.49);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (78, 'Cod Burger', 'burger', 8.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (79, 'Halibut Burger', 'burger', 11.39);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (80, 'Oyster Burger', 'burger', 11.49);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (81, 'Add Chips to Burger', 'burger', 4.49);

-- Sides
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (82, 'Bun & Butter', 'side', 1.25);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (83, 'Hand-Cut Chips', 'side', 5.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (84, 'C-Dog', 'side', 3.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (85, 'Oysters (Single)', 'side', 5.49);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (86, 'Coleslaw small', 'side', 3.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (87, 'Coleslaw large', 'side', 5.49);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (88, 'Mushy Peas', 'side', 3.49);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (89, 'Gravy', 'side', 2.99);

-- Take Out
-- DINNERS
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (90, 'Cod & Chips 1 pc', 'take_out', 12.98);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (91, 'Cod & Chips 2 pc', 'take_out', 20.97);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (92, 'Haddock & Chips 1 pc', 'take_out', 13.48);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (93, 'Haddock & Chips 2 pc', 'take_out', 21.97);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (94, 'Halibut & Chips 1 pc', 'take_out', 16.98);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (95, 'Halibut & Chips 2 pc', 'take_out', 28.97);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (96, 'Salmon & Chips 1 pc', 'take_out', 14.98);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (97, 'Salmon & Chips 2 pc', 'take_out', 24.97);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (98, 'Prawns & Chips 10 prawns', 'take_out', 15.98);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (99, 'Oysters & Chips 6 oysters', 'take_out', 25.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (100, 'Halibut Burger', 'take_out', 11.39);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (101, 'Salmon Burger', 'take_out', 9.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (102, 'Haddock Burger', 'take_out', 9.49);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (103, 'Cod Burger', 'take_out', 8.99);

-- Chicken Strips & Chips
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (104, 'Chicken Strips & Chips adult 5 strips', 'take_out', 14.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (105, 'Chicken Strips & Chips child 3 strips', 'take_out', 10.49);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (106, 'Chicken Strips & Caesar 5 strips', 'take_out', 16.99);

-- Sides (continued)
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (107, 'Cod 1 pc', 'side', 7.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (108, 'Haddock 1 pc', 'side', 8.49);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (109, 'Halibut 1 pc', 'side', 11.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (110, 'Salmon 1 pc', 'side', 9.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (111, 'Hand-Cut Chips', 'side', 4.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (112, 'C-Lovers Tartar', 'side', 1.39);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (113, 'Gravy (small)', 'side', 1.79);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (114, 'Gravy (large)', 'side', 2.79);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (115, 'Coleslaw (small)', 'side', 3.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (116, 'Coleslaw (large)', 'side', 4.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (117, 'Mushy Peas', 'side', 3.49);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (118, 'Caesar Salad (small)', 'side', 6.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (119, 'Caesar Salad (large)', 'side', 9.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (120, 'C-Food Chowder (small)', 'side', 5.49);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (121, 'C-Food Chowder (large)', 'side', 7.49);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (122, 'C-Dog', 'side', 3.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (123, 'Oysters (single)', 'side', 5.49);

-- Appetizers
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (124, 'Onion Rings (full order) (12)', 'appetizer', 10.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (125, 'Onion Rings (half order)(6)', 'appetizer', 5.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (126, 'Deep Fried Dill Pickles (6)', 'appetizer', 9.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (127, 'Side of Prawns (10)', 'appetizer', 12.49);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (128, 'Battered Mushrooms (12)', 'appetizer', 10.99);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (129, 'Popcorn Shrimp', 'appetizer', 10.99);

-- Beverages
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (130, '591ML Pop', 'beverage', 2.29);
INSERT INTO menu_items (menu_item_id, item_name, category, price) VALUES (131, '2L Pop', 'beverage', 2.99);

-- Family Packs (Cod, Haddock, Halibut)
#INSERT INTO family_packs (menu_item_id, pack_name, item_qty, chips_qty, coleslaw_qty, tartar_sauce_qty, price) VALUES (132, '6-COD', 6, 3, 1, 1, 59.99);
#INSERT INTO family_packs (menu_item_id, pack_name, item_qty, chips_qty, coleslaw_qty, tartar_sauce_qty, price) VALUES (133, '8-COD', 8, 4, 1, 1, 80.99);
#INSERT INTO family_packs (menu_item_id, pack_name, item_qty, chips_qty, coleslaw_qty, tartar_sauce_qty, price) VALUES (134, '10-COD', 10, 5, 2, 2, 100.99);
#INSERT INTO family_packs (menu_item_id, pack_name, item_qty, chips_qty, coleslaw_qty, tartar_sauce_qty, price) VALUES (135, '12-COD', 12, 5, 2, 2, 130.99);
#INSERT INTO family_packs (menu_item_id, pack_name, item_qty, chips_qty, coleslaw_qty, tartar_sauce_qty, price) VALUES (136, '6-HADDOCK', 6, 3, 1, 1, 61.99);
#INSERT INTO family_packs (menu_item_id, pack_name, item_qty, chips_qty, coleslaw_qty, tartar_sauce_qty, price) VALUES (137, '8-HADDOCK', 8, 4, 1, 1, 80.99);
#INSERT INTO family_packs (menu_item_id, pack_name, item_qty, chips_qty, coleslaw_qty, tartar_sauce_qty, price) VALUES (138, '10-HADDOCK', 10, 5, 2, 2, 104.99);
#INSERT INTO family_packs (menu_item_id, pack_name, item_qty, chips_qty, coleslaw_qty, tartar_sauce_qty, price) VALUES (139, '12-HADDOCK', 12, 5, 2, 2, 119.99);
#INSERT INTO family_packs (menu_item_id, pack_name, item_qty, chips_qty, coleslaw_qty, tartar_sauce_qty, price) VALUES (140, '6-HALIBUT', 6, 3, 1, 1, 80.19);
#INSERT INTO family_packs (menu_item_id, pack_name, item_qty, chips_qty, coleslaw_qty, tartar_sauce_qty, price) VALUES (141, '8-HALIBUT', 8, 4, 1, 1, 105.12);
#INSERT INTO family_packs (menu_item_id, pack_name, item_qty, chips_qty, coleslaw_qty, tartar_sauce_qty, price) VALUES (142, '10-HALIBUT', 10, 5, 2, 2, 130.99);
#INSERT INTO family_packs (menu_item_id, pack_name, item_qty, chips_qty, coleslaw_qty, tartar_sauce_qty, price) VALUES (143, '12-HALIBUT', 12, 5, 2, 2, 150.99);

-- Family Packs 
#INSERT INTO family_packs (menu_item_id, pack_name, item_qty, chips_qty, coleslaw_qty, tartar_sauce_qty, price) VALUES (144, '12-HALIBUT', 12, 5, 2, 2, 150.99);

-- The Take Out Special
#INSERT INTO specials (menu_item_id, name, item_qty, chips_qty, coleslaw_qty, pepsi_product_qty, price, feeds_people) VALUES (145, 'The Take Out Special', 2, 3, 1, 1, 46.99, 4);

-- Alternative items --  It's a many to many recursive for menu items and alternative items.
INSERT INTO alternative_items (menu_item_id, alternative_item_id) VALUES 
(1, 3), 
(2, 3), 
(4, 5), 
(4, 6), 
(5, 7),
(7, 8), 
(7, 9), 
(8, 9), 
(10, 11), 
(12, 13);
 
-- Tables in restaurant
INSERT INTO restaurant_tables (table_number, capacity)
VALUES
    (1, 4),
    (2, 4),
    (3, 4),
    (4, 4),
    (5, 4),
    (6, 4),
    (7, 2),
    (8, 2),
    (9, 2),
    (10, 2),
    (11, 2),
    (12, 2),
    (13, 2),
    (14, 2),
    (15, 2),
    (16, 2),
    (17, 2),
    (18, 2);


-- Menu Item Combinations (Recursive Many-to-Many Relationship) - It's a many to many recursive for menu items and menu items combinations.
INSERT INTO menu_item_combinations (combo_id, menu_item_id)
VALUES (1, 2), (1, 3), (2, 1), (2, 4), (3, 3), (3, 5), (4, 2), (4, 4), (5, 1), (5, 3);

-- Ingredients to Menu Items
INSERT INTO ingredients_to_menu_items (ingredient_id, menu_item_id, ingredient_needed_per_order)
VALUES (1, 1, 2.5), (2, 2, 1.5), (3, 3, 1), (4, 4, 0.75), (5, 5, 1.25), (6, 2, 2), (7, 3, 1.5), (8, 4, 1), (9, 1, 3), (10, 5, 1);

-- Menu Item Ingredients
INSERT INTO menu_item_ingredients (menu_item_id, ingredient_id)
VALUES (1, 1), (1, 9), (2, 2), (2, 6), (3, 3), (3, 7), (4, 4), (4, 8), (5, 5), (5, 10);

-- Food Inventory
INSERT INTO food_inventory (ingredient_id, quantity, unit) VALUES
(1, 10, 'count'),
(2, 5, 'count'),
(3, 10, 'count'),
(4, 5, 'count'),
(5, 5, 'count'),
(6, 20, 'kg'),
(7, 10, 'count'),
(8, 10, 'count'),
(9, 10, 'count'),
(10, 10, 'count'),
(11, 5, 'kg'),
(12, 5, 'count'),
(13, 5, 'count'),
(14, 5, 'count'),
(15, 5, 'count'),
(16, 5, 'count'),
(17, 5, 'count'),
(18, 5, 'count'),
(19, 5, 'count'),
(20, 5, 'count'),
(21, 5, 'count'),
(22, 5, 'count'),
(23, 5, 'count'),
(24, 5, 'count'),
(25, 5, 'count'),
(26, 5, 'count'),
(27, 5, 'count'),
(28, 5, 'count'),
(29, 5, 'count'),
(30, 5, 'count'),
(31, 5, 'count'),
(32, 5, 'count'),
(33, 5, 'count'),
(34, 5, 'count'),
(35, 5, 'count'),
(36, 5, 'count'),
(37, 5, 'count'),
(38, 5, 'count'),
(39, 5, 'count'),
(40, 5, 'count'),
(41, 5, 'count'),
(42, 5, 'count'),
(43, 5, 'count');

-- Stock Inventory
-- Proteins
INSERT INTO stock_inventory (supplier_id, ingredient_id, quantity, unit, cost_per_unit)
VALUES 
(1, 1, 50, 'kg', 12.50), -- Cod
(1, 2, 75, 'kg', 10.50), -- Haddock
(2, 3, 35, 'kg', 18.25), -- Halibut
(2, 4, 40, 'kg', 14.75), -- Salmon
(3, 5, 25, 'kg', 25.50), -- Prawns
(3, 6, 20, 'kg', 28.00), -- Oysters
(4, 7, 100, 'kg', 8.50), -- Chicken strips
(4, 8, 60, 'kg', 14.00); -- Bacon

-- Vegetables
INSERT INTO stock_inventory (supplier_id, ingredient_id, quantity, unit, cost_per_unit)
VALUES 
(5, 9, 200, 'kg', 2.25), -- Onions
(5, 10, 25, 'kg', 7.50), -- Dill pickles
(6, 11, 30, 'kg', 4.75), -- Mushrooms
(6, 12, 150, 'kg', 1.75), -- Lettuce (romaine)
(7, 13, 75, 'kg', 3.25), -- Tomatoes
(7, 14, 50, 'kg', 5.50); -- Assorted vegetables for chowder

-- Dry goods
INSERT INTO stock_inventory (supplier_id, ingredient_id, quantity, unit, cost_per_unit)
VALUES 
(8, 15, 200, 'kg', 1.50), -- Flour (batter flour)
(8, 16, 250, 'kg', 1.25), -- Flour (coating flour)
(9, 17, 50, 'kg', 2.50), -- Breadcrumbs
(9, 18, 15, 'kg', 6.50), -- Seasonings
(10, 19, 20, 'kg', 4.75), -- Spices
(10, 20, 150, 'kg', 0.75), -- Sugar
(11, 21, 100, 'kg', 0.50), -- Salt
(11, 22, 25, 'kg', 3.50), -- Croutons
(12, 23, 500, 'count', 0.05), -- Tea bags
(12, 24, 150, 'kg', 9.00), -- Coffee beans
(13, 25, 100, 'kg', 14.50); -- Popcorn shrimp

-- Dairy
INSERT INTO stock_inventory (supplier_id, ingredient_id, quantity, unit, cost_per_unit)
VALUES 
(14, 26, 25, 'kg', 35.00), -- Cheese (parmesan)
(14, 27, 500, 'ml', 1.25), -- Milk (regular)
(15, 28, 50, 'l', 20.00), -- Milk (chocolate)
(15, 29, 25, 'l', 35.00), -- Cream
(16, 30, 50, 'kg', 6.75); -- Butter

-- Cleaning supplies
INSERT INTO stock_inventory (supplier_id, ingredient_id, quantity, unit, cost_per_unit)
VALUES 
(1, 14, 5, 'L', 10.99), -- Dish soap
(1, 15, 10, 'kg', 15.99), -- Dishwasher detergent
(1, 16, 2, 'L', 8.99), -- Degreaser
(1, 27, 5, 'L', 7.99), -- Glass cleaner
(1, 28, 10, 'L', 12.99), -- All-purpose cleaner
(1, 39, 20, 'L', 18.99), -- Floor cleaner
(1, 30, 2, 'L', 14.99), -- Sanitizer
(1, 31, 10, 'count', 3.99), -- Cleaning cloths
(1, 32, 20, 'count', 4.99), -- Sponges
(1, 33, 2, 'count', 19.99), -- Brooms
(1, 34, 2, 'count', 24.99), -- Mops
(1, 35, 3, 'count', 8.99), -- Buckets
(1, 36, 100, 'count', 5.99), -- Trash bags

-- Disposable items
(1, 27, 100, 'count', 8.99), -- Takeout containers
(1, 28, 1000, 'count', 7.99), -- Napkins
(1, 29, 1000, 'count', 9.99), -- Straws
(1, 20, 500, 'count', 19.99), -- Disposable cutlery
(1, 21, 500, 'count', 8.99), -- Condiment packets
(1, 22, 200, 'count', 15.99), -- Aluminum foil
(1, 13, 200, 'count', 12.99), -- Plastic wrap
(1, 24, 200, 'count', 8.99), -- Wax or parchment paper

-- Kitchen consumables
(1, 25, 4, 'count', 49.99), -- Chef's knives
(1, 26, 5, 'count', 29.99), -- Cutting boards
(1, 23, 10, 'count', 12.99), -- Mixing bowls
(1, 38, 10, 'count', 8.99), -- Measuring cups and spoons
(1, 29, 10, 'count', 9.99), -- Cooking utensils (spatulas, tongs, ladles, etc.)
(1, 30, 10, 'count', 39.99), -- Pots and pans
(1, 11, 10, 'count', 19.99), -- Baking sheets
(1, 22, 20, 'count', 7.99), -- Food storage containers
(1, 33, 5, 'count', 14.99), -- Thermometers
(1, 14, 2, 'count', 29.99), -- Can opener
(1, 25, 1, 'count', 99.99); -- Blender

INSERT INTO stock_inventory (supplier_id, ingredient_id, quantity, unit, cost_per_unit)
VALUES (1, 37, 100, 'count', 0.05), -- Menus
(1, 18, 20, 'count', 3.50), -- Tablecloths or placemats
(1, 19, 10, 'count', 2.00), -- Napkin holders
(1, 10, 10, 'count', 1.50), -- Salt and pepper shakers
(1, 11, 5, 'count', 4.00), -- Condiment dispensers
(1, 12, 50, 'count', 1.00), -- Glasses
(1, 13, 50, 'count', 1.50), -- Plates
(1, 14, 50, 'count', 2.00), -- Silverware
(1, 15, 5, 'count', 8.00), -- Serving trays

-- Office supplies
(1, 36, 20, 'count', 0.25), -- Pens
(1, 27, 100, 'count', 0.03), -- Paper
(1, 18, 1, 'count', 50.00), -- Printer ink
(1, 29, 500, 'count', 0.01), -- Printer paper
(1, 40, 20, 'count', 1.00), -- Folders
(1, 31, 50, 'count', 0.10), -- Envelopes
(1, 22, 20, 'count', 0.50), -- Postage stamps

-- Maintenance supplies
(1, 43, 10, 'count', 1.50), -- Light bulbs
(1, 34, 20, 'count', 0.75), -- Batteries
(1, 35, 5, 'count', 5.00), -- Tools
(1, 36, 2, 'count', 20.00); -- HVAC filters
-- Prepared Inventory
-- INSERT INTO prepared_inventory (ingredient_id, quantity, unit) VALUES
-- (15, 10, 'kg'), -- onion rings
-- (16, 5, 'kg'), -- dill pickles
-- (32, 8, 'kg'), -- shrimp
-- (17, 3, 'kg'), -- mushrooms
-- (34, 10, 'kg'), -- prawns
-- (23, 20, 'kg'), -- fish
-- (24, 10, 'kg'), -- oysters
-- (18, 10, 'kg'), -- chicken strips
-- (27, 50, 'count'), -- chowder containers
-- (26, 20, 'kg'), -- Caesar salad dressing
-- (29, 30, 'kg'), -- coleslaw
-- (22, 10, 'kg'), -- garlic croutons
-- (30, 50, 'kg'), -- hand-cut chips
-- (25, 10, 'kg'), -- tartar sauce
-- (28, 10, 'kg'), -- mushy peas
-- (31, 10, 'kg'); -- gravy

-- Replenishment History
INSERT INTO replenishment_history (supplier_id, ingredient_id, replenishment_date, quantity, unit) VALUES
(1, 2, '2022-08-01', 50.00, 'kg'),
(3, 7, '2022-07-29', 5.00, 'l'),
(2, 18, '2022-07-25', 2.00, 'count'),
(4, 12, '2022-07-24', 3.50, 'kg'),
(1, 5, '2022-07-20', 20.00, 'kg'),
(3, 3, '2022-07-17', 10.00, 'kg'),
(2, 13, '2022-07-15', 1.00, 'count'),
(4, 23, '2022-07-12', 2.50, 'kg'),
(1, 10, '2022-07-10', 30.00, 'kg'),
(3, 1, '2022-07-07', 8.00, 'kg'),
(2, 19, '2022-07-05', 1.50, 'count'),
(4, 28, '2022-07-02', 1.00, 'l'),
(1, 15, '2022-06-29', 15.00, 'kg'),
(3, 11, '2022-06-27', 4.00, 'kg'),
(2, 26, '2022-06-25', 0.75, 'count');




#ORDER-RELATED**************************************************************************************************************************************
-- Orders
INSERT INTO orders (order_date, order_time, employee_id, table_id)
VALUES 
  ('2023-04-03', '18:00:00', 1, 2),
  ('2023-04-03', '18:10:00', 2, 4),
  ('2023-04-03', '18:20:00', 3, 1),
  ('2023-04-03', '18:30:00', 4, 5),
  ('2023-04-03', '18:40:00', 1, 3),
  ('2023-04-03', '18:50:00', 2, 2),
  ('2023-04-03', '19:00:00', 3, 1),
  ('2023-04-03', '19:10:00', 4, 5),
  ('2023-04-03', '19:20:00', 1, 4),
  ('2023-04-03', '19:30:00', 2, 3),
  ('2023-04-03', '19:40:00', 3, 2),
  ('2023-04-03', '19:50:00', 4, 1),
  ('2023-04-03', '20:00:00', 1, 5),
  ('2023-04-03', '20:10:00', 2, 4),
  ('2023-04-03', '20:20:00', 3, 3);


-- Order Items
INSERT INTO order_items (order_id, menu_item_id, quantity, special_request_id)
VALUES
(1, 1, 2, 1),
(1, 3, 1, 2),
(2, 2, 3, 3),
(2, 5, 2, 4),
(3, 4, 1, NULL),
(3, 2, 2, 5),
(4, 6, 2, 6),
(4, 1, 1, NULL),
(5, 3, 1, 7),
(5, 5, 3, 8),
(6, 2, 2, NULL),
(6, 1, 1, 9),
(7, 4, 2, 10),
(7, 6, 1, NULL),
(8, 1, 3, 11),
(8, 5, 2, NULL),
(9, 3, 1, 12),
(9, 2, 2, 13),
(10, 6, 2, 14),
(10, 4, 1, NULL),
(11, 1, 2, 15),
(11, 2, 1, NULL),
(12, 3, 1, NULL),
(12, 6, 1, NULL),
(13, 5, 3, NULL),
(13, 1, 1, NULL),
(14, 2, 2, NULL),
(14, 4, 1, NULL),
(15, 3, 1, NULL),
(15, 5, 2, NULL);
-- Special Requests
INSERT INTO special_requests (request_type, request_description, alternative_id)
VALUES
('light_batter', 'Just a light dusting of batter, please', 2),
('no_fries', 'Can I have a side salad instead of fries?', NULL),
('allergy', 'I have a nut allergy, please ensure my meal is nut-free', NULL),
('heavy_batter', 'I love lots of batter, please make it extra crispy', 9),
('no_fish', 'Can I have a chicken sandwich instead of the fish and chips?', 3),
('allergy', 'I am allergic to shellfish, please ensure my meal is safe', NULL),
('other', 'Can I have my steak cooked medium-rare?', 6),
('allergy', 'I have a gluten allergy, please make sure there is no gluten in my meal', 3),
('other', 'Can I have extra garlic on my shrimp?', NULL),
('no_fries', 'I am trying to be healthy, can I have a baked potato instead of fries?', 5),
('allergy', 'I am allergic to dairy, please ensure my meal is dairy-free', NULL),
('other', 'Can I have my burger without pickles?', 9),
('no_fish', 'I do not like fish, can I have a beef burger instead?', 11),
('allergy', 'I am allergic to soy, please ensure my meal is soy-free', 8),
('light_batter', 'Can I have a light batter on my onion rings?', NULL);

# When a special request is made or a dietary restriction/allergy is noted, follow these steps:
	#1. Check the ingredient_alternatives table for possible alternatives to the ingredients that are part of the menu item.
	#2. If an alternative ingredient is found, add a record to the special_requests table with the alternative_id and order_item_id.
	#3. Ensure that the kitchen staff is aware of these changes and can prepare the meals accordingly.

# INSERT INTO special_requests (request_description) VALUES ('Lightly Battered');
# INSERT INTO special_requests (request_description) VALUES ('Heavily Battered'); ######More can be addeddd....
#In case of allergies, special requests can also be put in.

-- Order Item Special Requests
INSERT INTO order_item_special_requests (order_item_id, special_request_id)
VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(11, 11),
(12, 12),
(13, 13),
(14, 14),
(15, 15);

-- Replacement Requests
INSERT INTO replacement_requests (order_item_id, reason, status)
VALUES
(1, 'Allergy to onions', 'pending'),
(2, 'Allergy to seafood', 'approved'),
(3, 'No cheese on burger', 'rejected'),
(4, 'Steak cooked too rare', 'completed'),
(5, 'Order incomplete', 'pending'),
(6, 'Extra bacon', 'approved'),
(7, 'No pickles on burger', 'rejected'),
(8, 'Fries overcooked', 'completed'),
(9, 'Allergy to gluten', 'pending'),
(10, 'Extra cheese', 'approved'),
(11, 'No lettuce on burger', 'rejected'),
(12, 'Burger undercooked', 'completed'),
(13, 'Allergy to dairy', 'pending'),
(14, 'Extra mayo on sandwich', 'approved'),
(15, 'No onions on sandwich', 'rejected');

#FOR REPLACEMENT_REQUESTS....
#When customer sends back food, insert new record into 'replacement_requests' table with corresponding 'order_item id':
#INSERT INTO replacement_requests (order_item_id, reason) VALUES (5, 'Undercooked fish');

#How to update status of replacemnt request:
#UPDATE replacement_requests SET status = 'approved' WHERE replacement_id = 1;

#How to create new order item for approved replacement:
#INSERT INTO order_items (order_id, menu_item_id, quantity) VALUES (1, 2, 1);

-- Payments
INSERT INTO payments (order_id, payer_number, payment_method, amount)
VALUES
(1, 5, 'credit_card', 45.00),
(2, 2, 'cash', 20.50),
(3, 3, 'credit_card', 18.00),
(4, 4, 'credit_card', 35.00),
(5, 1, 'gift_card', 50.00),
(6, 2, 'credit_card', 25.00),
(7, 1, 'cash', 42.00),
(8, 5, 'credit_card', 22.00),
(9, 4, 'gift_card', 15.50),
(10, 3, 'credit_card', 30.00),
(11, 1, 'cash', 27.00),
(12, 2, 'gift_card', 10.00),
(13, 5, 'credit_card', 39.00),
(14, 3, 'cash', 19.00),
(15, 4, 'credit_card', 44.50);

-- Gift Cards
INSERT INTO gift_cards (order_id, card_code, balance)
VALUES
(5, 'GC1234', 50.00),
(9, 'GC5678', 15.50),
(12, 'GC9101', 10.00),
(1, 'GC2345', 45.00),
(4, 'GC6789', 35.00),
(8, 'GC1112', 22.00),
(13, 'GC1314', 39.00),
(15, 'GC1516', 44.50),
(2, 'GC7890', 20.50),
(3, 'GC2345', 18.00);

-- All You Can Eat
INSERT INTO all_you_can_eat (menu_item_id, price, ayce_special_request_id)
VALUES
(1, 19.99, 1),
(2, 22.50, 2),
(3, 24.99, 3),
(4, 21.99, 4),
(5, 26.50, 5),
(6, 29.99, 6),
(7, 31.50, 7),
(8, 34.99, 8),
(9, 27.99, 9),
(10, 30.50, 10);

-- AYCE Special Requests
INSERT INTO ayce_special_requests (request_name)
VALUES
('Extra sauce'),
('Spicy'),
('Gluten-free'),
('Vegetarian'),
('No onions'),
('No cheese'),
('No mayo'),
('No tomato'),
('No pickles'),
('Extra cheese');


# INSERT INTO ayce_special_requests (request_name) VALUES ('only_fish'), ('only_fries'); #More can be added............

-- Coupons
INSERT INTO coupons (coupon_code, discount_type, discount_value, expiration_date)
VALUES
('SPRING21', 'percentage', 10.00, '2023-06-30'),
('EARLYBIRD', 'fixed_amount', 5.00, '2023-05-01'),
('LOVEFOOD', 'percentage', 10.00, '2023-12-31'),
('FREEMEAL', 'fixed_amount', 15.00, '2023-07-15'),
('SUMMER22', 'percentage', 5.00, '2024-08-31'),
('WEEKDAY10', 'percentage', 10.00, '2023-10-31'),
('WEEKEND15', 'percentage', 15.00, '2023-11-30'),
('NEWCUSTOMER', 'fixed_amount', 7.50, '2023-09-30'),
('LUNCH10', 'percentage', 10.00, '2024-01-31'),
('LUNCH5', 'percentage', 5.00, '2023-08-31'),
('DINNER20', 'percentage', 10.00, '2024-03-31'),
('FAMILYDEAL', 'fixed_amount', 10.00, '2023-07-31'),
('FRIENDS20', 'percentage', 20.00, '2023-10-15'),
('HAPPYHOUR', 'fixed_amount', 10.00, '2023-05-31'),
('BIRTHDAY', 'percentage', 25.00, '2023-12-15');

-- Order Discounts
INSERT INTO order_discounts (order_id, coupon_id, discount_amount)
VALUES
(1, 1, 5.00),
(2, 3, 12.00),
(3, 2, 3.50),
(4, 4, 15.00),
(5, 1, 10.00),
(6, 5, 2.00),
(7, 6, 8.00),
(8, 7, 5.50),
(9, 8, 7.50),
(10, 9, 3.00),
(11, 1, 8.00),
(12, 10, 10.00),
(13, 11, 25.00),
(14, 12, 12.00),
(15, 13, 7.00);

-- Refunds
INSERT INTO refunds (order_id, payment_id, refund_amount, refund_date, reason)
VALUES
(1, 1, 12.50, '2022-04-05', 'Incorrect order'),
(2, 2, 7.00, '2022-04-06', 'Cancelled order'),
(3, 3, 25.00, '2022-04-06', 'Overcharged'),
(4, 4, 8.50, '2022-04-07', 'Expired food'),
(5, 5, 14.75, '2022-04-08', 'Unsatisfactory service'),
(6, 6, 20.00, '2022-04-08', 'Damaged order'),
(7, 7, 5.00, '2022-04-09', 'Incorrect charge'),
(8, 8, 15.50, '2022-04-10', 'Food allergy'),
(9, 9, 18.00, '2022-04-11', 'Long wait time'),
(10, 10, 10.25, '2022-04-11', 'Damaged dish'),
(11, 11, 30.00, '2022-04-12', 'Overcooked food'),
(12, 12, 6.75, '2022-04-13', 'Small portion size'),
(13, 13, 9.50, '2022-04-13', 'Delayed order'),
(14, 14, 17.00, '2022-04-14', 'Incorrect charge'),
(15, 15, 12.00, '2022-04-15', 'Missing side dish');

-- Reservations
INSERT INTO reservations (customer_name, phone_number, reservation_date, reservation_time, party_size, table_id, cancellation_status)
VALUES
('John Smith', '555-1234', '2023-04-05', '18:00:00', 2, 3, 'active'),
('Jane Doe', '555-4321', '2023-04-06', '19:00:00', 4, 5, 'active'),
('Mike Johnson', '555-6789', '2023-04-07', '20:00:00', 6, 1, 'active'),
('Sara Lee', '555-9876', '2023-04-08', '18:30:00', 2, 2, 'active'),
('David Brown', '555-1111', '2023-04-09', '19:30:00', 3, 4, 'active'),
('Maria Garcia', '555-2222', '2023-04-10', '20:30:00', 2, 3, 'active'),
('James Smith', '555-3333', '2023-04-11', '18:00:00', 4, 5, 'active'),
('Lisa Nguyen', '555-4444', '2023-04-12', '19:00:00', 2, 1, 'active'),
('Daniel Kim', '555-5555', '2023-04-13', '20:00:00', 6, 2, 'active'),
('Michelle Lee', '555-6666', '2023-04-14', '18:30:00', 3, 4, 'active'),
('John Lee', '555-7777', '2023-04-15', '19:30:00', 2, 5, 'active'),
('Emily Kim', '555-8888', '2023-04-16', '20:30:00', 4, 1, 'active'),
('Alex Brown', '555-9999', '2023-04-17', '18:00:00', 2, 3, 'active'),
('Sophia Johnson', '555-0000', '2023-04-18', '19:00:00', 5, 2, 'active'),
('Olivia Davis', '555-1111', '2023-04-19', '20:00:00', 2, 4, 'active');
