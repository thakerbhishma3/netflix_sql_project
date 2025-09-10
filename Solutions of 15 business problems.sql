-- 15 Business Problems & Solutions (Germany Focus First)

-- 1. Find each year and the average numbers of content release in Germany on netflix. Return top 5 years with highest avg content release!
SELECT
  country,
  release_year,
  COUNT(show_id) as total_release,
  ROUND(
    COUNT(show_id)::numeric/
    (SELECT COUNT(show_id) FROM netflix WHERE country = 'Germany')::numeric * 100, 2
  ) as avg_release
FROM netflix
WHERE country = 'Germany'
GROUP BY country, 2
ORDER BY avg_release DESC
LIMIT 5;

-- 2. Find how many movies actor 'David Schütter' appeared in last 10 years!
SELECT * FROM netflix
WHERE
  casts LIKE '%David Schütter%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

-- 3. Find the top 10 actors who have appeared in the highest number of movies produced in Germany.
SELECT
  UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
  COUNT(*)
FROM netflix
WHERE country = 'Germany'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- 4. Count the number of Movies vs TV Shows
SELECT
  type,
  count(*) as total_count
FROM netflix
GROUP BY type;

-- 5. Find the most common rating for movies and TV shows
WITH RatingCounts AS (
  SELECT
    type,
    rating,
    COUNT(*) AS rating_count
  FROM netflix
  GROUP BY type, rating
),
RankedRatings AS (
  SELECT
    type,
    rating,
    rating_count,
    RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
  FROM RatingCounts
)
SELECT
  type,
  rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;

-- 6. List all TV Shows released in 2021
SELECT * FROM netflix
WHERE type = 'TV Show'
  AND release_year = 2021;

-- 7. Find the top 5 countries with the most content on Netflix
SELECT *
FROM (
  SELECT
    UNNEST(STRING_TO_ARRAY(country, ',')) as country,
    COUNT(*) as total_content
  FROM netflix
  GROUP BY 1
) as t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 10;

-- 8. Identify the longest movie
SELECT *
FROM netflix
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC;

-- 9. Find content added in the last 5 years
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

-- 10. Find all the movies/TV shows by director 'Rajiv Chilaka'
SELECT * FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';

-- 11. List all TV shows with more than 5 seasons
SELECT *
FROM netflix
WHERE TYPE = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;

-- 12. Count the number of content items in each genre
SELECT
  UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
  COUNT(*) as total_content
FROM netflix
GROUP BY 1;

-- 13. List all movies that are documentaries
SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries';

-- 14. Find all content without a director
SELECT * FROM netflix
WHERE director IS NULL;

-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.
SELECT
  category,
  TYPE,
  COUNT(*) AS content_count
FROM (
  SELECT *,
    CASE
      WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
      ELSE 'Good'
    END AS category
  FROM netflix
) AS categorized_content
GROUP BY 1, 2
ORDER BY 2;
