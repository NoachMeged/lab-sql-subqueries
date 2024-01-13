-- How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(*) AS copies_in_inventory
FROM (
    SELECT inventory.*
    FROM inventory
    JOIN film ON inventory.film_id = film.film_id
    WHERE film.title = 'Hunchback Impossible'
) AS subquery_result;

-- List all films whose length is longer than the average of all the films.
SELECT film_id, title, length
FROM sakila.film
WHERE length > (
    SELECT AVG(length)
    FROM sakila.film
);
-- Use subqueries to display all actors who appear in the film Alone Trip.
SELECT actor_id, first_name, last_name
FROM sakila.actor
WHERE actor_id IN (
    SELECT actor_id
    FROM sakila.film_actor
    WHERE film_id = (
        SELECT film_id
        FROM sakila.film
        WHERE title = 'Alone Trip'
    )
);

-- Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

SELECT film.film_id, film.title
FROM sakila.film
JOIN sakila.film_category ON film.film_id = film_category.film_id
JOIN sakila.category ON film_category.category_id = category.category_id
WHERE category.name = 'Family';

-- Get name and email from customers from Canada using subqueries. Do the same with joins.
-- Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, 
-- that will help you get the relevant information.

SELECT first_name, last_name, email
FROM sakila.customer
WHERE address_id IN (
    SELECT address_id
    FROM sakila.address
    WHERE city_id IN (
        SELECT city_id
        FROM sakila.city
        WHERE country_id = (
            SELECT country_id
            FROM sakila.country
            WHERE country = 'Canada'
        )
    )
);

-- Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. 
-- First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
SELECT film.film_id, film.title
FROM sakila.film
JOIN sakila.film_actor ON film.film_id = film_actor.film_id
JOIN (
    SELECT actor.actor_id
    FROM sakila.film_actor
    JOIN sakila.actor ON film_actor.actor_id = actor.actor_id
    GROUP BY actor.actor_id
    ORDER BY COUNT(*) DESC
    LIMIT 1
) AS most_prolific_actor ON film_actor.actor_id = most_prolific_actor.actor_id;

-- Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer
--  ie the customer that has made the largest sum of payments

SELECT
    customer.customer_id,
    customer.first_name,
    customer.last_name,
    film.film_id,
    film.title
FROM
    sakila.film
JOIN
    sakila.inventory ON film.film_id = inventory.film_id
JOIN
    sakila.rental ON inventory.inventory_id = rental.inventory_id
JOIN
    sakila.payment ON rental.rental_id = payment.rental_id
JOIN
    sakila.customer ON payment.customer_id = customer.customer_id
WHERE
    payment.customer_id = (
        SELECT
            customer_id
        FROM
            sakila.payment
        GROUP BY
            customer_id
        ORDER BY
            SUM(amount) DESC
        LIMIT 1
    );
-- Get the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.
SELECT
    p.customer_id,
    SUM(p.amount) AS total_amount_spent
FROM
    sakila.payment p
JOIN
    sakila.customer c ON p.customer_id = c.customer_id
GROUP BY
    p.customer_id
HAVING
    total_amount_spent > (
        SELECT
            AVG(total_amount_spent)
        FROM
            (SELECT
                customer_id,
                SUM(amount) AS total_amount_spent
            FROM
                sakila.payment
            GROUP BY
                customer_id) AS subquery
    );



