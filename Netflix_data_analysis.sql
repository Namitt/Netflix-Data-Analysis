-- Netflix Data Analysis

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    `type`         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);

-- Task 1. Count the Number of Movies vs TV Shows
SELECT 
    `type`,
    COUNT(*)
FROM netflix
GROUP BY 1;

-- Task2. Find the Most Common Rating for Movies and TV Shows
WITH RatingCounts AS (
    SELECT 
        `type`,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY `type`, rating
),
RankedRatings AS (
    SELECT 
        `type`,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY `type` ORDER BY rating_count DESC) AS `rank`
    FROM RatingCounts
)
SELECT 
    `type`,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE `rank` = 1;

-- Task 3. List All Movies Released in a Specific Year (e.g., 2020)
SELECT * 
FROM netflix
WHERE release_year = 2020;

-- Task 4. Find the Top 5 Countries with the Most Content on Netflix
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM numbers
    WHERE n <= 10
),
split_countries AS (
    SELECT 
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', n), ',', -1)) AS country
    FROM netflix, numbers
    WHERE n <= 1 + LENGTH(country) - LENGTH(REPLACE(country, ',', ''))
)
SELECT 
    country,
    COUNT(*) AS total_content
FROM split_countries
WHERE country IS NOT NULL AND country != ''
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;

-- Task 5. Identify the Longest Movie
SELECT *
FROM netflix
WHERE type = 'Movie'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC;

-- Task 6. Find Content Added in the Last 5 Years
SELECT *
FROM netflix
WHERE STR_TO_DATE(date_added, '%M %e, %Y') >= CURDATE() - INTERVAL 5 YEAR;

-- Task 7. Find All Movies/TV Shows by Director 'Kirsten Johnson'
SELECT *
FROM netflix
WHERE director LIKE '%Kirsten Johnson%';

-- Task 8. List All TV Shows with More Than 5 Seasons
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;
  
-- Task 9. Count the Number of Content Items in Each Genre
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 10
),
split_genres AS (
    SELECT 
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', n), ',', -1)) AS genre
    FROM netflix, numbers
    WHERE n <= 1 + LENGTH(listed_in) - LENGTH(REPLACE(listed_in, ',', ''))
)
SELECT 
    genre,
    COUNT(*) AS total_content
FROM split_genres
WHERE genre IS NOT NULL AND genre != ''
GROUP BY genre
ORDER BY total_content DESC;

-- Task 10.Find each year and the average numbers of content release in India on netflix.
-- return top 5 year with highest avg content release!
SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id) / 
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India') * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;

-- Task 11. List All Movies that are Documentaries
SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';

-- Task 12. Find All Content Without a Director
SELECT * 
FROM netflix
WHERE director IS NULL;

-- Task 13. Find How Many Movies Actor 'Roy Scheider' Appeared in the Last 10 Years
SELECT * 
FROM netflix
WHERE casts LIKE '%Roy Scheider%'
  AND release_year > YEAR(CURDATE()) - 10;
  
-- Task 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 20
),
split_actors AS (
    SELECT 
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(casts, ',', n), ',', -1)) AS actor
    FROM netflix
    CROSS JOIN numbers
    WHERE country = 'India'
      AND n <= 1 + LENGTH(casts) - LENGTH(REPLACE(casts, ',', ''))
)
SELECT 
    actor,
    COUNT(*) AS count
FROM split_actors
WHERE actor != ''
GROUP BY actor
ORDER BY count DESC
LIMIT 10;

-- Task 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;

