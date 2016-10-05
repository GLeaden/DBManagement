/*
Brought to you by G Leaden
10/05/2016
Lab5 SQL Queries - The Joins Three-quel
*/


/*1		Show the cities of agents booking an order for a customer whose id is 'c006'. Use joins this time; no subqueries. */
SELECT agents.city
FROM agents
INNER JOIN orders
	ON agents.aid=orders.aid
WHERE cid='c006';

/*2		Show the ids of products ordered through any agent who makes at least one order for a customer in Kyoto, sorted by pid from highest to lowest. Use joins; no subqueries. */
SELECT DISTINCT ord2.pid
FROM orders
INNER JOIN customers
	ON customers.cid=orders.cid
INNER JOIN agents
	ON customers.city='Kyoto'
INNER JOIN orders ord2
	ON ord2.aid = orders.aid
ORDER BY pid
	DESC;
-- ^^^  this one was a doozy  ^^^ 


/*3		Show the names of customers	who	have never placed an order.	Use	a subquery.*/
SELECT name
FROM customers
WHERE cid NOT IN (
	SELECT cid
    FROM orders
);

/*4 	 Show the	names	of	customers	who	have	never	placed	an	order.	Use	an	outer	join.	*/
SELECT name
FROM customers
LEFT OUTER JOIN orders
	ON customers.cid=orders.cid
WHERE orders.cid IS NULL;

/*5		Show	the	names	of	customers	who	placed	at	least	one	order	through	an	agent	in	their own	city,	along	with	those	agent(s')	names.	*/
SELECT DISTINCT customers.name, agents.name 
FROM customers
INNER JOIN orders
	ON customers.cid=orders.cid
INNER JOIN agents
	ON agents.aid=orders.aid
WHERE customers.city=agents.city;

/*6    Show	the	names	of	customers	and	agents	living	in	the	same	city,	along	with	the	name of	the	shared	city,	regardless	of	whether	or	not	the	customer	has	ever	placed	an	order	with	that	agent. */

SELECT DISTINCT customers.name, agents.name, customers.city
FROM customers
INNER JOIN agents
	ON customers.city=agents.city;

/*7     Show	the	name	and	city	of	customers	who	live	in	the	city	that	makes	the	fewest different	kinds	of	products.	(Hint:	Use	count	and	group	by	on	the	Products	table.)*/
-- NOT DONE AT ALL
SELECT customers.name, customers.city
FROM customers
INNER JOIN products
	ON customers.city=products.city
GROUP BY customers.city, customers.name
ORDER BY COUNT(products.city)
	ASC LIMIT 1;