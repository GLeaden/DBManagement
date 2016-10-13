/*1. Display the name and city of customers who live in any city that makes the most different kinds of products. 
(There are two cities that make the most different products. Return the name and city of customers from either one of those.) */

SELECT c.name, cities.city
FROM customers c, (	SELECT city, COUNT(city)
                    FROM products
                    GROUP BY city
                    HAVING COUNT(city) = (SELECT COUNT(city)
                                          FROM products
                                          GROUP BY city
                                          ORDER BY COUNT(city)
                                            DESC
                                            LIMIT 1)) as cities
where c.city=cities.city;

/*2. Display the names of products whose priceUSD is strictly below the average priceUSD, 
in reverse-alphabetical order. */

SELECT p.name
FROM products p
WHERE priceUSD < (	SELECT AVG(priceUSD)
                 	FROM products)
ORDER BY p.name
	DESC

/*3. Display the customer name, pid ordered, and the total for all orders, sorted by total 
from low to high. */

SELECT c.name, pid, SUM(totalUSD)
FROM customers c
INNER JOIN orders o ON (c.cid=o.cid)
GROUP BY c.name,pid
ORDER BY SUM(totalUSD)
	ASC

/*4. Display all customer names (in alphabetical order) and their total ordered, and 
nothing more. Use coalesce to avoid showing NULLs. */

SELECT coalesce(name),coalesce(SUM(totalUSD))
FROM customers c
INNER JOIN orders o ON (c.cid=o.cid)
GROUP BY name
ORDER BY name 	
	ASC
    
/*5. Display the names of all customers who bought products from agents based in New 
York along with the names of the products they ordered, 
and the names of the agents who sold it to them. */

SELECT c.name, p.name, a.name
FROM customers c
INNER JOIN orders o on o.cid=c.cid
INNER JOIN products p on p.pid=o.pid
INNER JOIN agents a on a.aid=o.aid
WHERE o.aid in ( SELECT DISTINCT a.aid
              	FROM agents a
              	INNER JOIN orders o on a.aid=o.aid
              	WHERE a.city='New York')

/*6. Write a query to check the accuracy of the dollars column in the Orders table. This 
means calculating Orders.totalUSD from data in other tables and 
comparing those values to the values in Orders. totalUSD. Display all rows in Orders where 
Orders.totalUSD is incorrect, if any. */

SELECT o.ordnum, o.totalUSD, ((p.priceUSD * o.qty) * (1-(c.discount/100))) AS CalculatedOrder
FROM orders o
	INNER JOIN customers c ON c.cid=o.cid
    INNER JOIN products p ON p.pid=o.pid
WHERE o.totalUSD != (p.priceUSD * o.qty) * (1-(c.discount/100))
GROUP BY ordnum, c.cid, p.pid
ORDER BY ordnum 
	ASC

/*7. What’s the difference between a LEFT OUTER JOIN and a RIGHT OUTER JOIN? Give 
example queries in SQL to demonstrate.(Feel free to use the CAP database to make your points here.)*/

/*

A left outer join will look at the items on the left side (the first table) of the two 
tables and attempt to match them with corresponding items on the right (the second table).

A right outer join will look at the items on the right side (the second table) of the two 
tables and attempt to match them with corresponding items  on the left (the first table).)

an example of  a left outer join is below. this query selects all of the cities in the 
customers table and any cities in the products table that match them
(we will have all the customer cities AND the cities from products that match the cities in customers)
*/
SELECT c.city
FROM customers c
LEFT OUTER JOIN products p on p.city = c.city
/*



an example of a right outer join is below. this query selects all of the cities in the products table
and any cities in the customers table that match them
(we will have all the product cities AND the cities from products that match the cities in customers.
BUT IN THIS CASE we have some values that do not match up, so we will have NULL values in the table)
*/
SELECT c.city
FROM customers c
LEFT OUTER JOIN products p on p.city = c.city





