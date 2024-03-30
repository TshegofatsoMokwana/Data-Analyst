-- Independent Project: Music store analyst

-- Which tracks appeared in the most playlists?
-- How many playlists did they appear in?

SELECT TrackId, COUNT(PlaylistId)
FROM playlist_track
GROUP BY TrackId
ORDER BY 2 DESC;

SELECT TrackId, COUNT(PlaylistId) AS 'no_of_playlists'
FROM playlist_track
GROUP BY TrackId
HAVING no_of_playlists >= 5
ORDER BY 2 DESC;

WITH tracks_most_playlists AS(
SELECT TrackId, COUNT(PlaylistId) AS 'no_of_playlists'
FROM playlist_track
GROUP BY TrackId
HAVING no_of_playlists >= 5
ORDER BY 2 DESC
)
SELECT tracks_most_playlists.TrackId, tracks.name, tracks_most_playlists.no_of_playlists
FROM tracks_most_playlists
JOIN tracks
 ON tracks_most_playlists.TrackId = tracks.TrackId;
 
 
 
-- Which tracks generated the most revenue? From which album and genre?
 
 SELECT TrackId, SUM(UnitPrice) AS 'Revenue'
FROM invoice_items
GROUP BY TrackId
HAVING Revenue > 3
ORDER BY Revenue DESC;

WITH most_revenue AS(
SELECT TrackId, SUM(UnitPrice) AS 'Revenue'
FROM invoice_items
GROUP BY TrackId
HAVING Revenue > 3
ORDER BY Revenue DESC
)
SELECT most_revenue.TrackId, most_revenue.revenue, tracks.name, tracks.GenreId, tracks.AlbumId
FROM most_revenue
JOIN tracks
 ON most_revenue.TrackId = tracks.TrackId;
 
 SELECT most_revenue2.TrackId, most_revenue2.Revenue, most_revenue2.Name, most_revenue2.GenreId, genres.name AS 'Genre_Name', most_revenue2.AlbumId
 FROM most_revenue2
 JOIN genres
  ON most_revenue2.GenreId = genres.GenreId;
  
 SELECT most_revenue3.TrackId, most_revenue3.Revenue, most_revenue3.Name, most_revenue3.GenreId, most_revenue3.Genre_Name, most_revenue3.AlbumId, albums.Title AS 'Album_Name'
  FROM most_revenue3
  JOIN albums
   ON most_revenue3.AlbumId = albums.AlbumId;

   
   
-- Which countries have the highest sales revenue?
-- What percent of total revenue does each country make up?

SELECT BillingCountry, SUM(Total) AS 'Total_Revenue'
FROM invoices
GROUP BY BillingCountry
ORDER BY Total_Revenue DESC;

SELECT BillingCountry, 
SUM(Total) AS 'Total_Revenue', 
ROUND(SUM(Total)*100 / (SELECT SUM(Total) FROM invoices), 2) AS 'Revenue_Percentage'
FROM invoices
GROUP BY BillingCountry
ORDER BY Total_Revenue DESC;



--How many customers did each employee support?
--what is the average revenue for each sale, and what is their total sale?

SELECT SupportRepId, COUNT(CustomerId) AS 'no_of_customers_supported'
FROM customers
GROUP BY SupportRepId;

SELECT employees.EmployeeId, 
employees.FirstName, 
employees.LastName, 
COUNT(customers.CustomerId) AS 'no_of_customers_supported', 
ROUND(AVG(invoices.Total), 2) AS 'average_sales', 
ROUND(SUM(invoices.Total), 2) AS 'total_sales'
FROM employees
JOIN customers
 ON employees.EmployeeId = customers.SupportRepId
JOIN invoices
 ON customers.CustomerId = invoices.CustomerId
GROUP BY customers.SupportRepId;



--Do longer or shorter length albums tend to generate more revenue?

SELECT albums.AlbumId,
albums.Title,
COUNT(tracks.TrackId) AS 'no_of_tracks'
FROM albums
JOIN tracks
 ON albums.AlbumId = tracks.AlbumId
GROUP BY 1
ORDER BY 3 DESC;

WITH no_of_tracks_per_album AS(
SELECT albums.AlbumId,
albums.Title,
COUNT(tracks.TrackId) AS 'no_of_tracks'
FROM albums
JOIN tracks
 ON albums.AlbumId = tracks.AlbumId
GROUP BY 1
ORDER BY 3 DESC
)
SELECT no_of_tracks_per_album.*,
ROUND(SUM(invoice_items.UnitPrice)/(no_of_tracks_per_album.no_of_tracks), 2) AS 'avg_revenue_per_album'
FROM invoice_items
JOIN tracks
 ON invoice_items.TrackId = tracks.TrackId
JOIN no_of_tracks_per_album
 ON tracks.AlbumId = no_of_tracks_per_album.AlbumId
GROUP BY no_of_tracks_per_album.no_of_tracks
ORDER BY no_of_tracks_per_album.no_of_tracks DESC;



--Is the number of times a track appear in any playlist a good indicator of sales?

SELECT TrackId,
COUNT(PlaylistId) AS 'Playlist_count'
FROM playlist_track
GROUP BY TrackId
ORDER BY Playlist_count DESC;

WITH playlistcount_per_track AS(
SELECT TrackId,
COUNT(PlaylistId) AS 'Playlist_count'
FROM playlist_track
GROUP BY TrackId
ORDER BY Playlist_count DESC
)
SELECT playlistcount_per_track.*,
ROUND(SUM(invoices.Total)/playlistcount_per_track.Playlist_count, 2) AS 'avg_revenue_per_track'
FROM playlistcount_per_track
JOIN invoice_items
 ON playlistcount_per_track.TrackId = invoice_items.TrackId
JOIN invoices
 ON invoice_items.InvoiceId = invoices.InvoiceId
GROUP BY playlistcount_per_track.TrackId
ORDER BY playlistcount_per_track.Playlist_count DESC;



--How much revenue is generated each year, and what is its percent change from the previous year?

SELECT 
CAST(strftime('%Y', InvoiceDate) AS INTEGER)-1 AS 'PreviousYear',
CAST(strftime('%Y', InvoiceDate) AS INTEGER) AS 'CurrentYear',
ROUND(SUM(invoices.Total), 2) AS 'TotalRevenue'
FROM invoices
GROUP BY 2;

WITH Revenue AS(
SELECT 
CAST(strftime('%Y', InvoiceDate) AS INTEGER)-1 AS 'PreviousYear',
CAST(strftime('%Y', InvoiceDate) AS INTEGER) AS 'CurrentYear',
ROUND(SUM(invoices.Total), 2) AS 'TotalRevenue'
FROM invoices
GROUP BY 2
)
SELECT curr.PreviousYear,
prev.TotalRevenue AS 'PrevTotalRevenue',
curr.CurrentYear,
curr.TotalRevenue AS 'CurrTotalRevenue',
ROUND(((curr.TotalRevenue-prev.TotalRevenue)/prev.TotalRevenue)*100, 2) AS 'PercentageChange'
FROM Revenue curr
JOIN Revenue prev
 ON curr.PreviousYear = prev.CurrentYear;

