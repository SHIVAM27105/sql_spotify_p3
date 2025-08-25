-- SPOTIFY PROJECT

-- TABLE CREATION

DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

-- PRELIMINARY QUESTIONS...

SELECT * FROM spotify;

SELECT COUNT(DISTINCT album) FROM spotify;
-- AFTER INSPECTION, 2 SONGS ARE HAVING DURATION AS 0 MIN WHICH IS NOT POSSIBLE. HENCE WE DELETE THEM NOW.

DELETE FROM spotify WHERE duration_min = 0;
SELECT * FROM spotify;

-- BUSINESS PROBLEMS SOLVED...

-- Retrieve the names of all tracks that have more than 1 billion streams.
SELECT track FROM spotify WHERE stream > 1000000000;

-- List all albums along with their respective artists.
SELECT DISTINCT album, artist FROM spotify;

-- Get the total number of comments for tracks where licensed = TRUE.
SELECT SUM(comments) AS total_comments FROM spotify WHERE licensed = 'true';

-- Find all tracks that belong to the album type single.
SELECT track FROM spotify WHERE album_type = 'single';

-- Count the total number of tracks by each artist.
SELECT artist, COUNT(*) FROM spotify GROUP BY 1 ORDER BY 2 ASC;

-- Calculate the average danceability of tracks in each album.
SELECT album, AVG(danceability) AS avg_danceability FROM spotify GROUP BY 1 ORDER BY 2 DESC;

-- Find the top 5 tracks with the highest energy values.
SELECT track, AVG(energy) FROM spotify GROUP BY 1 ORDER BY 2 DESC LIMIT 5;

-- List all tracks along with their views and likes where official_video = TRUE.
SELECT track, SUM(views) AS total_views, SUM(likes) AS total_likes FROM spotify
WHERE official_video = 'true'
GROUP BY 1 ORDER BY 2 DESC;

-- For each album, calculate the total views of all associated tracks.
SELECT * FROM spotify;
SELECT album, track, SUM(views) FROM spotify GROUP BY 1,2 ORDER BY 3 DESC;

-- Retrieve the track names that have been streamed on Spotify more than YouTube.
SELECT track, streamed_on_youtube, streamed_on_Spotify FROM (
SELECT track,
COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END),0) AS streamed_on_youtube,
COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END),0) AS streamed_on_Spotify
FROM spotify
GROUP BY 1
)
WHERE
streamed_on_Spotify > streamed_on_youtube AND streamed_on_youtube != 0;

-- Find the top 3 most-viewed tracks for each artist using window functions.
SELECT artist, track, total_views, rank FROM (
SELECT artist, track, SUM(views) AS total_views, DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views)DESC) AS rank
FROM spotify GROUP BY 1,2
) WHERE rank <= 3;

-- Write a query to find tracks where the liveness score is above the average.
SELECT * FROM spotify;
SELECT track, artist, liveness FROM spotify WHERE
liveness > (SELECT AVG(liveness) FROM spotify);

-- Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
WITH t2
AS (
SELECT album, MAX(energy) AS MAX_ENERGY, MIN(energy) AS MIN_ENERGY
FROM spotify GROUP BY 1)
SELECT album, (MAX_ENERGY-MIN_ENERGY) AS DIFF_ENERGY
FROM t2 ORDER BY 2 DESC;