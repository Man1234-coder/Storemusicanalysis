-- 1.	Who is the senior most employee based on job title?

Select * from employee
order by levels desc
limit 1

-- 2.	Which countries have the most invoices?

Select count(total) as c, billing_country from invoice
group by billing_country
order by c desc;	

-- 3. what are top 3 values of total invoice?

select * from invoice
order by total desc
limit 3

-- 4.	which city has the best customers? we would like to throw a promotional music festival in the city we made the most money. write a query that returns one city that has the highest sum of invoice totals. return both the city name & sum of all invoice totals.

Select sum(total) as Total_invoice, billing_city from invoice
group by billing_city
order by Total_invoice desc
limit 1;

-- 5. who is the best customer? The customer who has spent the most money will be declared the best customer. write a query that returns the person who has spent the most money.

Select customer.customer_id, customer.first_name,customer.last_name, sum(invoice.total) as Total from customer 
inner join invoice 
ON customer.customer_id=invoice.customer_id
group by customer.customer_id
order by total desc

-- 6. Write a query to return the email, first name, last name & genre of all rock music listeners. Return your list ordered alphabetically by email starting with A. 

Select DISTINCT email,first_name,last_name from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
where track_id IN 
(Select track_id from track
join genre
ON track.genre_id=genre.genre_id
where genre.name LIKE 'Rock')
order by email;

-- 7. Lets invite the artist who have written the most rock music in our dataset. Write a query that returns the artist name and total track count of the top 10 rock bands.  

Select artist.artist_id, artist.name, count(album.artist_id) as number_of_songs
from track
join album on track.album_id=album.album_id
join artist on album.artist_id=artist.artist_id
join genre on track.genre_id=genre.genre_id
where genre.name LIKE 'Rock'
group by artist.artist_id
order by number_of_songs desc
limit 10

-- 8. Return all the track names that have a song length longer that the avreage song length. Return the name and miliseconds for each track. order by the song length with the longest songs listest first. 

Select name,milliseconds from track
where milliseconds>
(Select avg(milliseconds) from track)
order by milliseconds desc;

-- 9. Find how much amount spent by each customer on artist? Write a query to return customer name, artist name and total spent.

With best_selling_artist As (
Select artist.artist_id, artist.name as Artist_name, sum(invoice_line.unit_price*invoice_line.quantity) as Total_amount
from invoice_line 
join track on invoice_line.track_id=track.track_id
join album on album.album_id=track.album_id
join artist on artist.artist_id=album.artist_id
group by 1
order by 3 desc
limit 1
)
Select c.customer_id, c.first_name, c.last_name , bsa.Artist_name , sum(il.unit_price*il.quantity) As amount_spent
from invoice i
join customer c on c.customer_id=i.customer_id
join invoice_line il on il.	invoice_id=i.invoice_id 
join track t on il.track_id=t.track_id
join album al on al.album_id=t.album_id
join best_selling_artist bsa on bsa.artist_id=al.artist_id
group by 1,2,3,4
order by 5 desc;

-- 10.	We want to find out the most popular music genre for each country. We determine the most popular genre as the genre with the highest amount of purchase. Write as query that returns each country along with the top genre. For countries where the maximum number of purchases is shared return all genres.

WITH popular_genre As (
Select count(invoice_line.unit_price) as Purchases, customer.country, genre.name, genre.genre_id,
ROW_number() over(partition by customer.country order by count(invoice_line.unit_price) desc) As rono
from invoice_line
join invoice on invoice.invoice_id=invoice_line.invoice_id
join customer on customer.customer_id=invoice.customer_id
join track on track.track_id=invoice_line.track_id
join genre on genre.genre_id=track.genre_id
group by 2,3,4
order by 2 asc, 1 desc
)
Select * from popular_genre where rono<=1;



