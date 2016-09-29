/*
Brought to you by G Leaden
9/28/2016
Lab4 SQL Queries - The Subqueries Sequel
*/

/*1 Get the cities of agents booking an order for a customer whose cid is 'c006'. */
SELECT city
FROM Agents
WHERE aid in (
	SELECT aid
	FROM Orders
	WHERE cid in (
		SELECT cid
		FROM Customers
		WHERE cid = 'c006'
	)
);

/*2 Get the ids of products ordered through any agent who takes at least one order from a 
customer in Kyoto, sorted by pid from highest to lowest. */
SELECT pid
FROM Products
WHERE pid in (
	SELECT pid
	FROM Orders
	WHERE aid in (
		SELECT aid
		FROM Orders	
		WHERE cid in (
			SELECT cid
			FROM Customers
			WHERE city = 'Kyoto'
		)
	)
)
ORDER BY pid ASC;


/*3 Get the ids and names of customers who did not place an order through agent a03. */
SELECT cid, name
FROM Customers
WHERE cid in (
	SELECT cid
	FROM Orders
	WHERE aid LIKE 'a0%'
		EXCEPT
	SELECT cid
	FROM Orders
	WHERE aid = 'a03'
	
);

/*4	Get the ids of customers who ordered both product p01 and p07. */
SELECT cid
FROM Customers
WHERE cid in (
	SELECT cid
	FROM Orders
	WHERE pid = 'p01'
		INTERSECT
	SELECT cid
	FROM Orders
	WHERE pid = 'p07'
);

/*5	Get the ids of products not ordered by any customers who placed any order through agent a08 in pid order from highest to lowest. */
SELECT distinct pid
FROM Orders
WHERE cid NOT in (
	SELECT cid
	FROM Orders
	WHERE aid = 'a08'
)
ORDER BY pid DESC;

/*6	Get the name, discounts, and city for all customers who place orders through agents in Dallas or New York. */
SELECT name, discount, city
FROM Customers
WHERE cid in (
	SELECT cid
	FROM Orders
	WHERE aid in (
		SELECT aid
		FROM Agents
		WHERE city = 'New York'
			OR city = 'Dallas'
	)
);

/* 7 Get all customers who have the same discount as that of any customers in Dallas or London.*/
SELECT name
FROM Customers
WHERE discount in (
	SELECT discount
	FROM Customers
	WHERE city = 'Dallas' OR city = 'London'
);


/* 8 Tell me about check constraints: What are they? What are they good for? What’s the advantage of putting that sort of thing inside the database? Make up some examples of good uses of check constraints and some examples of bad uses of check constraints. Explain the differences in your examples and argue your case.


    Check constraints are constraints or limitations which specify a requirement to be met for an entire column in a database table. Check constraints are good for limiting responses to receive more accurate or specific information, for example, if there was an entry asking for a Yes or No response, a check constraint could be implemented to ensure only Yes and No are entered. The advantage of putting a check constraint inside a database is getting true / relevant information for manipulating the data at a future date. 
	
    An example of a good check constraint is to check entry values for a birthday to ensure that they are born within the past 200 years so the information can be accurate and not mis-clicked or intentionally false/misleading. Another good check constraint is to check     to make sure prices recorded in a POS system database are >=0 so you cannot have something “sell” for negative dollars. If you were to intentionally “sell” for negative dollars (return an item) you could create a new field for returns but there should not ever be a sale on an item that subtracts money entirely. As for the birthday, the difference between this date check constraint and the one below is that this date constraint has no real world application where it would be necessary. No one has lived to 199 years old so there is no need to set a precedent higher than that and the constraint would only help prevent the spread of misinformation.
	
    Some examples of bad check constraints include: setting a max sale amount for a POS system database so that you cannot record a sale past a certain dollar amount, or restricting a date input if it is past the current date on local time. While both of these constraints sound applicable and good in theory, when applied you can run into issues such as a very large catering order from your POS system that cannot record your sale due to the price cap. Even if the intended purpose was to prevent accidental inaccurate information there are real life scenarios that require a lack of restraint. The same goes for restricting a date, while you don't want people to input the incorrect date, if one was planning ahead or possibly in a different time zone they could have a different date than the database does in its local time so again the restraint would harm the entry of accurate data.
	

*/

