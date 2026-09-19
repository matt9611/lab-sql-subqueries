-- LAB | SQL Subqueries
-- Database: Sakila
-- MySQL-compatible solutions

USE sakila;


-- 1. Number of copies of "Hunchback Impossible" in inventory
SELECT
    f.title,
    COUNT(i.inventory_id) AS copies_in_inventory
FROM film AS f
LEFT JOIN inventory AS i
    ON f.film_id = i.film_id
WHERE f.title = 'Hunchback Impossible'
GROUP BY f.film_id, f.title;


-- 2. Films longer than the average film length
SELECT
    film_id,
    title,
    length AS film_length_minutes
FROM film
WHERE length > (
    SELECT AVG(length)
    FROM film
)
ORDER BY length DESC, title;


-- 3. Actors who appear in "Alone Trip"
SELECT
    a.actor_id,
    a.first_name,
    a.last_name
FROM actor AS a
WHERE a.actor_id IN (
    SELECT fa.actor_id
    FROM film_actor AS fa
    WHERE fa.film_id = (
        SELECT f.film_id
        FROM film AS f
        WHERE f.title = 'Alone Trip'
    )
)
ORDER BY a.last_name, a.first_name;


-- 4. Films in the Family category
SELECT
    f.film_id,
    f.title
FROM film AS f
WHERE f.film_id IN (
    SELECT fc.film_id
    FROM film_category AS fc
    WHERE fc.category_id = (
        SELECT c.category_id
        FROM category AS c
        WHERE c.name = 'Family'
    )
)
ORDER BY f.title;


-- 5a. Canadian customers using subqueries
SELECT
    c.first_name,
    c.last_name,
    c.email
FROM customer AS c
WHERE c.address_id IN (
    SELECT a.address_id
    FROM address AS a
    WHERE a.city_id IN (
        SELECT ci.city_id
        FROM city AS ci
        WHERE ci.country_id = (
            SELECT co.country_id
            FROM country AS co
            WHERE co.country = 'Canada'
        )
    )
)
ORDER BY c.last_name, c.first_name;


-- 5b. Canadian customers using joins
SELECT
    c.first_name,
    c.last_name,
    c.email
FROM customer AS c
JOIN address AS a
    ON c.address_id = a.address_id
JOIN city AS ci
    ON a.city_id = ci.city_id
JOIN country AS co
    ON ci.country_id = co.country_id
WHERE co.country = 'Canada'
ORDER BY c.last_name, c.first_name;


-- 6. Films starring the most prolific actor
-- The nested query returns all actors tied for the highest film count.
SELECT
    a.actor_id,
    a.first_name,
    a.last_name,
    f.film_id,
    f.title
FROM actor AS a
JOIN film_actor AS fa
    ON a.actor_id = fa.actor_id
JOIN film AS f
    ON fa.film_id = f.film_id
WHERE a.actor_id IN (
    SELECT actor_film_counts.actor_id
    FROM (
        SELECT
            actor_id,
            COUNT(film_id) AS number_of_films
        FROM film_actor
        GROUP BY actor_id
    ) AS actor_film_counts
    WHERE actor_film_counts.number_of_films = (
        SELECT MAX(number_of_films)
        FROM (
            SELECT COUNT(film_id) AS number_of_films
            FROM film_actor
            GROUP BY actor_id
        ) AS film_counts
    )
)
ORDER BY a.last_name, a.first_name, f.title;


-- 7. Films rented by the most profitable customer
-- Profitability is measured by the customer's total payment amount.
SELECT DISTINCT
    c.customer_id,
    c.first_name,
    c.last_name,
    f.title
FROM customer AS c
JOIN payment AS p
    ON c.customer_id = p.customer_id
JOIN rental AS r
    ON p.rental_id = r.rental_id
JOIN inventory AS i
    ON r.inventory_id = i.inventory_id
JOIN film AS f
    ON i.film_id = f.film_id
WHERE c.customer_id IN (
    SELECT customer_totals.customer_id
    FROM (
        SELECT
            customer_id,
            SUM(amount) AS total_amount_spent
        FROM payment
        GROUP BY customer_id
    ) AS customer_totals
    WHERE customer_totals.total_amount_spent = (
        SELECT MAX(total_amount_spent)
        FROM (
            SELECT SUM(amount) AS total_amount_spent
            FROM payment
            GROUP BY customer_id
        ) AS payment_totals
    )
)
ORDER BY c.last_name, c.first_name, f.title;


-- 8. Customers who spent more than the average customer total
SELECT
    customer_totals.customer_id AS client_id,
    ROUND(customer_totals.total_amount_spent, 2) AS total_amount_spent
FROM (
    SELECT
        customer_id,
        SUM(amount) AS total_amount_spent
    FROM payment
    GROUP BY customer_id
) AS customer_totals
WHERE customer_totals.total_amount_spent > (
    SELECT AVG(total_amount_spent)
    FROM (
        SELECT
            customer_id,
            SUM(amount) AS total_amount_spent
        FROM payment
        GROUP BY customer_id
    ) AS customer_totals_for_average
)
ORDER BY total_amount_spent DESC;
