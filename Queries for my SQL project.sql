/* Question Set#1 Number 1 */


/*Query used to find all the family friendly movie categories and also 
count the number of times each category has been rented
*/

SELECT f.title AS film_Title, c.name AS FilmCategory, COUNT (f.rental_duration) AS Rental_count
FROM film AS f
JOIN film_category AS fc
ON f.film_id = fc.film_id
JOIN category AS c
ON fc.category_id = c.category_id
JOIN inventory AS i
ON i.film_id = f.film_id
JOIN rental AS r
ON r.inventory_id = i.inventory_id
WHERE c.name = 'Animation' OR c.name = 'Children' OR c.name = 'Classics' OR c.name= 'Comedy' OR c.name = 'Family' OR c.name= 'Music'
GROUP BY 1,2
ORDER BY 2;




/* Question Set#2 Number 1 */


/*What month is the most favorable for movie rentals for Store 1 and Store 2?*/


SELECT stf.store_id, DATE_PART('year',r.rental_date) AS Year, DATE_PART('month',r.rental_date) AS Month,
       COUNT(r.rental_id) AS Monthly_rentals
FROM store AS s
JOIN staff AS stf
  ON stf.store_id = s.store_id
JOIN payment AS p
  ON stf.staff_id = p.staff_id
JOIN rental as r
  ON r.rental_id = p.rental_id
JOIN customer AS c
  ON c.customer_id = r.customer_id
GROUP BY 1,2,3
ORDER BY 3;




/* Question Set#2 Number 2 */


/* We would like to know who were our top 10 paying customers, how many payments they made on a monthly basis during 2007,
and what was the amount of the monthly payments. Can you write a query to capture the customer name, month and year of payment,
and total payment amount for each month by these top 10 paying customers?*/

WITH Customer_Rentals AS

    (
        SELECT c.customer_id AS All_customers, c.first_name AS FirstName, c.last_name AS LastName, SUM(p.amount) AS Total_spent
        FROM payment AS p
        JOIN customer AS c
        ON c.customer_id = p.customer_id
        GROUP BY 1,2,3
        ORDER BY 2 DESC
        LIMIT 10
     ),

    Sakilarentals AS

    (
        SELECT c.customer_id AS Customers, DATE_TRUNC('month',p.payment_date) AS Date_of_payment, COUNT(p.amount) AS Numberof_monthlyPayments,
        SUM (amount) AS Monthly_orderUSD
        FROM payment AS p
        JOIN customer AS c
        ON c.customer_id = p.customer_id
        GROUP BY 1,2
        ORDER BY 2

    )

  

    SELECT CONCAT (cr.FirstName,'  ',cr.Lastname) AS FullName,
    s.Date_of_payment AS Monthof_payment , s.Monthly_orderUSD AS Amountpaid_perMonth,
    s.Numberof_monthlyPayments AS Countof_monthlyOrder

    FROM Customer_Rentals AS cr
    JOIN Sakilarentals AS s
      ON s.Customers = cr.All_customers
    ORDER BY 1,2;





/* Question Set#2 Number 3 */

/*Finally, for each of these top 10 paying customers, I would like to find out the difference across their monthly payments during 2007.
Please go ahead and write a query to compare the payment amounts in each successive month.
Repeat this for each of these 10 paying customers. Also, it will be tremendously helpful if you can identify the customer name
who paid the most difference in terms of payments.*/

WITH Customer_Rentals AS

    (
        SELECT c.customer_id AS All_customers, c.first_name AS FirstName, c.last_name AS LastName, SUM(p.amount) AS Total_spent
        FROM payment AS p
        JOIN customer AS c
        ON c.customer_id = p.customer_id
        GROUP BY 1,2,3
        ORDER BY 2 DESC
        LIMIT 10
     ),

    Sakilarentals AS

    (
        SELECT c.customer_id AS Customers, DATE_TRUNC('month',p.payment_date) AS Date_of_payment, COUNT(p.amount) AS Numberof_monthlyPayments,
        SUM (amount) AS Monthly_orderUSD
        FROM payment AS p
        JOIN customer AS c
        ON c.customer_id = p.customer_id
        GROUP BY 1,2
        ORDER BY 2

    ),

    Customer_monthlyUsage AS

    (

    SELECT CONCAT (cr.FirstName,'  ',cr.Lastname) AS FullName,
    s.Date_of_payment AS Monthof_payment , s.Monthly_orderUSD AS Amountpaid_perMonth,
    s.Numberof_monthlyPayments AS Countof_monthlyOrder

    FROM Customer_Rentals AS cr
    JOIN Sakilarentals AS s
      ON s.Customers = cr.All_customers
    ORDER BY 1,2

    )
    SELECT FullName, Amountpaid_perMonth, Monthof_payment,
           LEAD (Amountpaid_perMonth) OVER (ORDER BY Monthof_payment) AS lead,
           LEAD (Amountpaid_perMonth) OVER (ORDER BY Monthof_payment) - Amountpaid_perMonth AS lead_difference,
           LAG  (Amountpaid_perMonth) OVER (ORDER BY Monthof_payment) AS lag,
           Amountpaid_perMonth -  LAG  (Amountpaid_perMonth) OVER (ORDER BY Monthof_payment) AS lag_difference
    FROM Customer_monthlyUsage
    ORDER BY 1,3;




