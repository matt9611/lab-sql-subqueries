USE sakila;

SELECT COUNT(*) AS number_of_copies
FROM inventory
WHERE film_id = (
    SELECT film_id
    FROM film
    WHERE title = 'Hunchback Impossible'
);



select title
from film
where length >  ( select  AVG(length) from film  );



select 
first_name
from actor
where actor_id in (select actor_id from film_actor where film_id = ( select film_id from film where title = 'Alone Trip'));

