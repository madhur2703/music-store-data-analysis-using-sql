--1. who is the senior most employee based on the job title?

select * from employee
order by levels desc
limit 1

--2.which countries have the most invoices?

select count(*) as c, billing_country from invoice
group by billing_country
order by c desc

--3.what are top 3 values of total invoice?

select * from invoice
order by total desc
limit 3

--4. which cityhas the best customers? we would like to throw a promotional music 
--festival in the city made the most money.
--write a query that return one city that has the highest sum of invoice totals.
--return both the city name& sum of all invoice totals

select sum(total) as invoice_total, billing_city
from invoice
group by billing_city
order by invoice_total desc

--who is the best customer?the customer who has spent the most money will be 
--declared the bes customer. write a query that returns the person who has spent
--the most money.

select customer.customer_id, customer.first_name, customer.last_name ,sum(invoice.total) as total
from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc
limit 1

--6.write query to return the email,first name, lastname,&genre of all rock music listeners, retuen your list 
--ordered alphabatically by email starting with A

select distinct email,first_name,last_name
from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice_line.invoice_id=invoice.invoice_id
--(JOIN track on invoice_line.track_id= track.track_id
--join genre on track.genre_id= genre.genre_id
--where genre.name='Rock'
--order by email;)
where track_id in(
      select track_id from track
      join genre on track.genre_id= genre.genre_id
      where genre.name like 'Rock'
)
order by email;

--7.let's invite the artist who have written the most rock music in our dataset. write a query that returs the artist
--name and total track count of the top 10 rock bands
select artist.artist_id,artist.name, count(artist.artist_id) as number_of_songs
from track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by number_of_songs DESC
limit 10;

/* Q3: Return all track names that have a song length longer than average song length . return the name ang
miliseconds for each track . order by song length with the longest songs listed first.*/
select name, milliseconds
from track
where milliseconds >(
	select avg(milliseconds) as avg_track_length
	from track)
order by milliseconds desc;
/*HARD QUES 

8: Find how much amount spent by each customer on artists ? write a query to return customer name ,
artist name and total spent .*/

WITH best_selling_artist AS(
	 select artist.artist_id as artist_id, artist.name as artist_name,
	 SUM(invoice_line.unit_price*invoice_line.quantity) as total_sales
	 from invoice_line
	 join track on track.track_id = invoice_line.track_id
	 join album on album.album_id = track.album_id
	 join artist on artist.artist_id = album.artist_id
	 group by 1
	 order by 3 desc
	 limit 1
)
select c.customer_id, c.first_name , c.last_name, bsa.artist_name, 
SUM(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;

/* we want to fimd out the most popular music genre from each country. we determine the most popular genre as the 
genre with the most highest amount of purchases. write a query that return each country along with the top genre. 
for countries where the maximum number of purchases is shared return all genres. */

with popular_genre as
(
	select count(invoice_line.quantity) as purchases, customer.country,genre.name,genre.genre_id,
	ROW_NUMBER() over(partition by customer.country order by count(invoice_line.quantity) desc ) as rowno
	from invoice_line
	join invoice on invoice.invoice_id=invoice_line.invoice_id
	join customer on customer.customer_id=invoice.customer_id
    join track on track.track_id= invoice_line.track_id
	join genre on genre.genre_id=track.genre_id
	group by 2,3,4
	order by 2 asc, 5 desc
)
select * from popular_genre where rowno<=1

/*Write a query that determines the customer that has spent the most on music for each country. Write a query that 
returns the country along with the top customer and how much they spent. For countries where the top amount spent 
is shared, provide all customers who spent this amount*/

WITH Customter_with_country AS (
    SELECT customer.customer_id,first_name,last_name, billing_country, SUM(total) AS total_spending, 
	ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUm (total) DESC) AS RowNo
    FROm invoice
    JOIN customer ON customer.customer_id=invoice.customer_id
    GROUP BY 1,2,3,4
    ORDER BY 4 ASC,5 DESC
)
SELECT * FROM Customter_with_country WHERE RowNo <= 1









