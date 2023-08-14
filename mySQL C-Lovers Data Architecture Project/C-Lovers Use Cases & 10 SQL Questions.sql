#Authors: Jaiden Angeles & Tianci Qiao
#Date: April 5, 2023
#Assignment: Final Project - Field Exercise as a Database Architect for an On-Campus Business
#Topic: C-Lovers Fish & Chips SQL Queries and 10 Report Questions 

USE C_Lovers;

#This contains our use cases, the SQL code created to implement our use cases, and 10 questions a manager may request data and information for qith SQL.
##################################################################################################################################################################################################
-- USE CASES
##################################################################################################################################################################################################
-- Use case 1
# Title: Restaurant Inventory and Supplier Management System

# Actors: Restaurant Manager, Supplier, Supplier Contact

# Description:

# The Restaurant Manager logs into the inventory management system and navigates to the "Suppliers" tab.

# The Restaurant Manager views a list of all current suppliers and their contact information.

# The Restaurant Manager selects a supplier and views a list of all the ingredients that the supplier provides.

# The Restaurant Manager navigates to the "Food Inventory" tab and views a list of all current ingredients in stock, along with their quantities and units.

# The Restaurant Manager selects an ingredient and views a list of all current suppliers for that ingredient, along with their contact information and cost per unit.

# The Restaurant Manager selects a supplier and creates a new replenishment order, specifying the quantity and unit of the ingredient to be ordered.

# The system generates a new replenishment order and sends it to the selected supplier.

# The supplier receives the replenishment order and processes the order.

# The supplier logs into the system and navigates to the "Replenishment History" tab to view the details of the new order.

# The supplier updates the order status to "Fulfilled" after the order has been shipped.

# The Restaurant Manager receives the shipment and logs into the system to update the inventory levels.

# The Restaurant Manager navigates to the "Food Inventory" tab and updates the quantity of the received ingredient.

# The system generates a new entry in the "Replenishment History" table to record the details of the new shipment.

# The Restaurant Manager logs into the system and views the "Menu Items" tab.

# The Restaurant Manager selects a menu item and views a list of all the ingredients required to prepare the item.

# The Restaurant Manager navigates to the "Ingredients" tab and views a list of all current ingredients, including their types and usage categories.

# The Restaurant Manager selects an ingredient and views a list of all menu items that require the ingredient.

# The Restaurant Manager navigates to the "Suppliers" tab and views a list of all current suppliers.

# The Restaurant Manager selects a supplier and views a list of all current ingredients that the supplier provides.

# The Restaurant Manager creates a new purchase order for an ingredient, specifying the quantity, unit, and supplier.

# The system generates a new purchase order and sends it to the selected supplier.

# The supplier receives the purchase order and processes the order.

# The supplier logs into the system and navigates to the "Replenishment History" tab to view the details of the new order.

# The supplier updates the order status to "Fulfilled" after the order has been shipped.

# The Restaurant Manager receives the shipment and logs into the system to update the inventory levels.

# The Restaurant Manager navigates to the "Food Inventory" tab and updates the quantity of the received ingredient.

# The system generates a new entry in the "Replenishment History" table to record the details of the new shipment.

-- 1 View all current suppliers and their contact information
SELECT supplier_name, supply_type, storage_condition, delivery_day, contact_name, phone_number, email_address
FROM suppliers
JOIN supplier_contacts ON suppliers.supplier_id = supplier_contacts.supplier_id;

-- 2 View all the ingredients that a selected supplier provides
SELECT ingredient_name, ingredient_type, ingredient_used_in
FROM ingredients
JOIN stock_inventory ON ingredients.ingredient_id = stock_inventory.ingredient_id
JOIN suppliers ON stock_inventory.supplier_id = suppliers.supplier_id
WHERE suppliers.supplier_id = selected_supplier_id;


-- 3 View a list of all current ingredients in stock, along with their quantities and units
SELECT ingredient_name, quantity, unit
FROM ingredients
JOIN food_inventory ON ingredients.ingredient_id = food_inventory.ingredient_id;

-- 4 View a list of all current suppliers for a selected ingredient, along with their contact information and cost per unit
SELECT supplier_name, supply_type, storage_condition, delivery_day, contact_name, phone_number, email_address, cost_per_unit, selected_ingredient_id
FROM suppliers
JOIN supplier_contacts ON suppliers.supplier_id = supplier_contacts.supplier_id
JOIN stock_inventory ON suppliers.supplier_id = stock_inventory.supplier_id
JOIN food_inventory ON stock_inventory.ingredient_id = food_inventory.ingredient_id
JOIN ingredients ON food_inventory.ingredient_id = ingredients.ingredient_id
WHERE ingredients.selected_ingredient_id = 1
LIMIT 0, 1000;

-- 5 Create a new replenishment order for a selected supplier and ingredient
INSERT INTO replenishment_history (supplier_id, ingredient_id, replenishment_date, quantity, unit)
# VALUES (selected_supplier_id, selected_ingredient_id, NOW(), replenishment_history.quantity, replenishment_history.unit);
VALUES (1, 1, NOW(), 20, 'count');

-- 6 Update the food inventory table with the received ingredient quantity
UPDATE food_inventory
JOIN replenishment_history ON food_inventory.ingredient_id = replenishment_history.ingredient_id
SET food_inventory.quantity = food_inventory.quantity + replenishment_history.quantity
WHERE food_inventory.ingredient_id = 1;

-- 7 View the replenishment history for a selected supplier and ingredient
SELECT *
FROM replenishment_history
WHERE supplier_id = 1 AND ingredient_id = 1;

-- 8 View a list of all menu items that require a selected ingredient
SELECT item_name, price
FROM menu_items
JOIN menu_item_ingredients ON menu_items.menu_item_id = menu_item_ingredients.menu_item_id
WHERE menu_item_ingredients.ingredient_id = 1;

-- 9 View a list of all current ingredients, including their types and usage categories
SELECT ingredient_name, ingredient_type, ingredient_used_in
FROM ingredients;

-- 10 View a list of all current menu items, along with their prices and categories
SELECT item_name, category, price
FROM menu_items;

-- 11 View a list of all current suppliers and their contact information, along with the ingredients they supply and the cost per unit
SELECT supplier_name, supply_type, storage_condition, delivery_day, contact_name, phone_number, email_address, ingredient_name, cost_per_unit
FROM suppliers
JOIN supplier_contacts ON suppliers.supplier_id = supplier_contacts.supplier_id
JOIN stock_inventory ON suppliers.supplier_id = stock_inventory.supplier_id
JOIN ingredients ON stock_inventory.ingredient_id = ingredients.ingredient_id;

-- 12 Create a new purchase order for a selected supplier and ingredient
INSERT INTO replenishment_history (supplier_id, ingredient_id, replenishment_date, quantity, unit)
# VALUES ((selected_supplier_id), (selected_ingredient_id), NOW(), (purchase_quantity), (purchase_unit));
VALUES (2, 2, NOW(), 300, 'kg');

-- 13 Update the food inventory table with the purchased ingredient quantity
UPDATE food_inventory
SET quantity = quantity + 300
WHERE ingredient_id = 2;

-- 14 View the purchase history for a selected supplier and ingredient
SELECT *
FROM replenishment_history
WHERE supplier_id = 2 AND ingredient_id = 2;


#######################################################################
-- Use case 2
-- Before go to restaurant, make reservation
-- not a seperate use case, it is an additional process. Focus on family or party
-- For reservations, add a step to create a reservation and another step to cancel a reservation (if needed):
-- Create a reservation
INSERT INTO reservations (customer_name, phone_number, reservation_date, reservation_time, party_size, table_id)
VALUES ('David Brown', '555-1111', '2023-04-09', '19:30:00', 3, 4);

-- 16 Cancel a reservation
UPDATE reservations
SET cancellation_status = 'active', cancellation_date = CURDATE()
WHERE reservation_id = 5;

SELECT * FROM reservations WHERE reservation_id = LAST_INSERT_ID();

-- You can verify the updated record by running:
SELECT * FROM reservations WHERE reservation_id = 3;

########################################################################################################################################
-- Title:  USE CASE customer look at menu
-- 1. Retrieve all menu items with their prices and gluten_friendly status
SELECT 
  mi.menu_item_id,
  mi.item_name,
  mi.category,
  mi.price,
  mi.gluten_friendly
FROM 
  menu_items mi;

-- 2. Retrieve ingredients for each menu item
SELECT
  mi.menu_item_id,
  mi.item_name,
  ing.ingredient_id,
  ing.ingredient_name
FROM
  menu_items mi
JOIN
  menu_item_ingredients ming ON mi.menu_item_id = ming.menu_item_id
JOIN
  ingredients ing ON ming.ingredient_id = ing.ingredient_id;

-- 3. Retrieve alternative items for each menu item
SELECT
  mi1.menu_item_id,
  mi1.item_name AS original_item,
  mi2.menu_item_id AS alternative_item_id,
  mi2.item_name AS alternative_item
FROM
  menu_items mi1
JOIN
  alternative_items alt ON mi1.menu_item_id = alt.menu_item_id
JOIN
  menu_items mi2 ON alt.alternative_item_id = mi2.menu_item_id;

-- 4. Retrieve menu item combinations
SELECT
  mi1.menu_item_id AS combo_id,
  mi1.item_name AS combo_name,
  mi2.menu_item_id,
  mi2.item_name
FROM
  menu_items mi1
JOIN
  menu_item_combinations mic ON mi1.menu_item_id = mic.combo_id
JOIN
  menu_items mi2 ON mic.menu_item_id = mi2.menu_item_id;

-- 5. Retrieve All You Can Eat menu items with special requests and prices
SELECT
  mi.menu_item_id,
  mi.item_name,
  ayce.price AS ayce_price,
  sr.request_id,
  sr.request_name
FROM
  menu_items mi
JOIN
  all_you_can_eat ayce ON mi.menu_item_id = ayce.menu_item_id
LEFT JOIN
  ayce_special_requests sr ON ayce.ayce_special_request_id = sr.request_id;


###############################################################################################################################################
-- Use case 3
-- USE CASE customer order
-- Step 1: Add a new order
INSERT INTO orders (order_date, order_time, employee_id, table_id)
VALUES ('2023-04-04', '19:30:00', 1, 1); -- Replace the date, time, employee_id, and table_id with actual values
SET @order_id = LAST_INSERT_ID(); -- Store the order_id for later use

-- Step 2: Add order items
INSERT INTO order_items (order_id, menu_item_id, quantity)
VALUES
  (@order_id, 1, 2), -- Replace menu_item_id and quantity with actual values for the first menu item
  (@order_id, 2, 1); -- Replace menu_item_id and quantity with actual values for the second menu item
SET @order_item_id_1 = LAST_INSERT_ID() - 1; -- Store the order_item_id for the first menu item
SET @order_item_id_2 = LAST_INSERT_ID(); -- Store the order_item_id for the second menu item

-- Step 3: Add special requests
INSERT INTO special_requests (request_type, request_description, alternative_id)
VALUES
  ('no_fries', NULL, NULL), -- Replace request_type, request_description, and alternative_id with actual values for the first special request
  ('allergy', 'Peanut allergy', NULL); -- Replace request_type, request_description, and alternative_id with actual values for the second special request
SET @special_request_id_1 = LAST_INSERT_ID() - 1; -- Store the special_request_id for the first special request
SET @special_request_id_2 = LAST_INSERT_ID(); -- Store the special_request_id for the second special request

-- Step 4: Link special requests to order items
INSERT INTO order_item_special_requests (order_item_id, special_request_id)
VALUES
  (@order_item_id_1, @special_request_id_1), -- Link the first special request to the first order item
  (@order_item_id_2, @special_request_id_2); -- Link the second special request to the second order item

SELECT
  oi.order_item_id,
  mi.item_name,
  oi.quantity,
  sr.request_type,
  sr.request_description
FROM
  order_items oi
JOIN menu_items mi ON oi.menu_item_id = mi.menu_item_id
LEFT JOIN special_requests sr ON oi.special_request_id = sr.special_request_id
WHERE
  oi.order_id = 1 and 2; -- Replace <order_id> with the actual order_id

#####################################################################################################################################################################
-- Use case 4
-- USE CASE customer check out
-- Calculate the order total (subtotal):
SET @order_total = (SELECT SUM(mi.price * oi.quantity) FROM order_items oi JOIN menu_items mi ON oi.menu_item_id = mi.menu_item_id WHERE oi.order_id = 1);

-- Apply the discount from the coupon (if any):
INSERT INTO order_discounts (order_id, coupon_id, discount_amount)
SELECT
  1,
  c.coupon_id,
  ROUND(
    CASE
      WHEN c.discount_type = 'percentage' THEN @order_total * (c.discount_value / 100)
      ELSE c.discount_value
    END,
    2
  ) AS discount_amount
FROM
  coupons c
WHERE
  c.coupon_code = 'LOVEFOOD'
  AND c.expiration_date >= CURDATE();

-- Record the payment method and amount:
-- Record the payment method and amount:
SET @discount_amount = (SELECT COALESCE(SUM(discount_amount), 0) FROM order_discounts WHERE order_id = 1);
SET @gift_card_amount = (SELECT balance FROM gift_cards WHERE card_code = 'GC2345' LIMIT 1);
SET @tip_amount = 5;

INSERT INTO payments (order_id, payer_number, payment_method, amount)
VALUES
  (1, 1, 'credit_card', @order_total - @discount_amount + @gift_card_amount + @tip_amount);

-- Display the final amount to be paid by the customer:
SELECT
  amount AS final_amount
FROM
  payments
WHERE
  order_id = 1;

-- Update the gift card balance if used:
SET SQL_SAFE_UPDATES = 0;

UPDATE gift_cards
SET balance = balance - @order_total + @discount_amount
WHERE card_code = 'GC2345';

-- Display the updated gift card balance:
SELECT
  balance AS updated_balance
FROM
  gift_cards
WHERE
  card_code = 'GC2345';

SET SQL_SAFE_UPDATES = 1;

-- Record any tips for the employee:
INSERT INTO tips (employee_id, tip_amount, tip_date)
VALUES
  (1, @tip_amount, CURDATE());

-- Display the tip amount:
SELECT
  tip_amount AS tip_amount
FROM
  tips
WHERE
  employee_id = 1;
-- For refunds, add a step to create a refund record after the payment step:
-- Record a refund (if necessary)
INSERT INTO refunds (order_id, payment_id, refund_amount, refund_date, reason)
VALUES (1, 1, 12.50, CURDATE(), 'Incorrect order');

SELECT * FROM refunds WHERE order_id = 1 AND payment_id = 1;


###############################################################################################################################################
-- Use case 5
-- USE CASE empolyees shift
-- 1.Check if an employee is absent on the shift date:
SELECT COUNT(*) as is_absent
FROM staff_absences
WHERE employee_id = 1 AND absence_date = CURDATE();

-- 2.Check if an employee has a role assigned:
SELECT COUNT(*) as role_assigned
FROM employee_roles
WHERE employee_id = 1;

-- 3.Check if an employee is available for the shift:
SELECT COUNT(*) as is_unavailable
FROM unavailable_days
WHERE
  employee_id = 1
  AND day_of_week = DAYNAME(CURDATE())
  AND TIME(NOW()) BETWEEN start_time AND end_time;

-- 4.Clock in at the beginning of a shift:
INSERT INTO clock_in_out (employee_id, clock_in, clock_out, date)
VALUES
  (1, '2023-03-27', '2023-04-03 16:30:00', CURDATE());
-- 5. Clock out at the end of a shift:
UPDATE clock_in_out
SET clock_out = NOW()
WHERE
  employee_id = 1
  AND date = CURDATE();
-- 6. Calculate hours worked for the shift:
UPDATE shifts s
JOIN clock_in_out c ON s.employee_id = c.employee_id AND s.date = c.date
SET s.hours_worked = TIMESTAMPDIFF(HOUR, c.clock_in, c.clock_out)
WHERE
  s.employee_id = 1
  AND s.date = CURDATE();

-- 7. Insert a new shift record:
INSERT INTO shifts (employee_id, shift_start, shift_end, hours_worked, date, day_of_week)
SELECT
  employee_id,
  clock_in,
  clock_out,
  TIMESTAMPDIFF(HOUR, clock_in, clock_out) AS hours_worked,
  date,
  DAYNAME(clock_in) AS day_of_week
FROM
  clock_in_out
WHERE
  employee_id = 1
  AND date = CURDATE();

-- 8.Get the shift details before the shift starts:
SELECT *
FROM shifts
WHERE employee_id = 1 AND date = CURDATE();

-- 9.Get the shift details after the shift ends:
SELECT *
FROM shifts
WHERE employee_id = 1 AND date = CURDATE() AND shift_end IS NOT NULL;


##################################################################################################################################################################################################
-- 10 Questions
##################################################################################################################################################################################################

-- 1.Restaurant Sales Report: What were the total sales across all orders for today (orders, payments, giftcards, discounts, all_you_can_eat)?
-- To calculate total sales for today, sum the order amounts from the orders table, and then add the values from payments, gift cards, and discounts. Also, consider the revenue from all-you-can-eat orders.
SELECT SUM(p.amount) + SUM(g.balance) - SUM(od.discount_amount) + SUM(ayce.price)
FROM orders o
LEFT JOIN payments p ON o.order_id = p.order_id
LEFT JOIN gift_cards g ON o.order_id = g.order_id
LEFT JOIN order_discounts od ON o.order_id = od.order_id
LEFT JOIN all_you_can_eat ayce ON o.table_id = ayce.ayce_id
WHERE o.order_date = CURDATE(); #The answer is 0, so check if there were payments today.
#Checking:
SELECT COUNT(*) FROM orders WHERE DATE(order_date) = CURDATE(); #Shows 0.

#Thus, the total sales are null. However, this would work if there were sales.

-- 2.Time Report: At what times during the day are the most orders being placed and least orders being placed (Maybe 1 hour intervals through the day)?
-- To find the busiest and least busy hours, group the orders by the hour they were placed and count the number of orders per hour. Then, identify the hours with the highest and lowest order counts. This is displayed in 24-hour format.
SELECT EXTRACT(HOUR FROM order_time) AS hour, COUNT(*) AS num_orders
FROM orders
GROUP BY hour
ORDER BY num_orders DESC;

-- 3.find the employee who made the most tips in April, 2023
-- This query joins the employees and tips tables, and filters for tips made in March 2023. It then uses a subquery to find the maximum tip amount in March 2023, and filters for tips that have that amount. 
-- Finally, it groups the results by employee and selects the employee's first name, last name, and maximum tip amount.
SELECT e.first_name, e.last_name, MAX(t.tip_amount) AS max_tip_amount
FROM employees e
JOIN tips t ON e.employee_id = t.employee_id
WHERE MONTH(t.tip_date) = 4
AND YEAR(t.tip_date) = 2023
AND t.tip_amount = (
    SELECT MAX(t2.tip_amount)
    FROM tips t2
    WHERE MONTH(t2.tip_date) = 4
    AND YEAR(t2.tip_date) = 2023
)
GROUP BY e.employee_id;

-- 4.What is the total amount paid for orders made on a specific date? What about any day?
SELECT SUM(amount) AS total_amount_paid
FROM payments
WHERE DATE(order_id) = '2023-04-01';

#Any day:
SELECT DATE(order_date) AS date, COUNT(*) AS num_orders
FROM orders
GROUP BY date
ORDER BY num_orders DESC
LIMIT 1;

-- 5.How many employees have the "Manager" role?
SELECT COUNT(*) AS num_managers
FROM employee_roles
JOIN roles ON employee_roles.role_id = roles.role_id
WHERE roles.role_name = 'Manager';

-- 6.What is the total number of hours worked by all employees on a specific day?
SELECT SUM(hours_worked) AS total_hours_worked
FROM shifts
WHERE date = '2023-04-01';

-- 7.Which menu items have ingredients that are stored in the "frozen" condition?
SELECT DISTINCT mi.item_name
FROM menu_items mi
JOIN ingredients_to_menu_items itmi ON mi.menu_item_id = itmi.menu_item_id
JOIN ingredients i ON itmi.ingredient_id = i.ingredient_id
JOIN stock_inventory si ON i.ingredient_id = si.ingredient_id
JOIN suppliers s ON si.supplier_id = s.supplier_id
WHERE s.storage_condition = 'frozen';

-- 8.What is the total number of hours worked by each employee?
SELECT e.first_name, e.last_name, SUM(hours_worked) AS total_hours_worked
FROM employees e
JOIN shifts s ON e.employee_id = s.employee_id
GROUP BY e.first_name, e.last_name;

-- 9.Which employees mentored another employee for the longest period of time?
SELECT m.mentor_id, m.mentee_id, e1.first_name AS mentor_first_name, e1.last_name AS mentor_last_name,
       e2.first_name AS mentee_first_name, e2.last_name AS mentee_last_name,
       DATEDIFF(m.end_date, m.start_date) AS mentoring_duration
FROM mentoring m
JOIN employees e1 ON m.mentor_id = e1.employee_id
JOIN employees e2 ON m.mentee_id = e2.employee_id
WHERE DATEDIFF(m.end_date, m.start_date) = (
  SELECT MAX(DATEDIFF(end_date, start_date))
  FROM mentoring
);

-- 10.List all orders with the customer name, order date, menu item name, and price for each menu item.
SELECT r.customer_name, o.order_date, mi.item_name, mi.price
FROM orders o
JOIN restaurant_tables rt ON o.table_id = rt.table_id
JOIN reservations r ON rt.table_id = r.table_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN menu_items mi ON oi.menu_item_id = mi.menu_item_id;
