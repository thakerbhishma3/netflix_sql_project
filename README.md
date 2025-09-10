# Netflix Movies and TV Shows Data Analysis using SQL

![]((https://github.com/thakerbhishma3/netflix_sql_project/blob/main/logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Emphasize Germany's Netflix content trends and key contributors.
- Analyze content type distribution, ratings, genres, and release patterns.
- Categorize content based on description keywords to understand content nature.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
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
```

## Business Problems and Solutions

### 1. Find Each Year and the Average Number of Content Releases in Germany (Top 5 Years)


```sql
SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'Germany')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'Germany'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;
```

**Objective:** Rank years by average content releases from Germany.


### 2. Find How Many Movies Actor 'David Schütter' Appeared in Last 10 Years

```sql
SELECT * 
FROM netflix
WHERE casts LIKE '%David Schütter%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```

**Objective:** Count movies featuring actor David Schütter recently.

### 3.Find the Top 10 Actors Appearing in the Most Movies Produced in Germany


```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country = 'Germany'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;
```

**Objective:** Identify most frequent actors in German productions.

### 4. Count the Number of Movies vs TV Shows
```sql
SELECT 
    type,
    COUNT(*)
FROM netflix
GROUP BY type;
```

**Objective:** Analyze distribution of content types.

### 5. Find the Most Common Rating for Movies and TV Shows

```sql
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
```

**Objective:** Identify common ratings for each content type.

### 6. List All TV Shows Released in 2021

```sql
SELECT * 
FROM netflix
WHERE 
    type = 'TV Show'
    AND release_year = 2021;
```

**Objective:** Retrieve all TV shows released in 2021.

### 7. Find the Top 5 Countries with the Most Content on Netflix


```sql
SELECT *
FROM (
    SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
        COUNT(*) AS total_content
    FROM netflix
    GROUP BY country
) AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;
```

**Objective:** Identify top countries by content volume.

### 8. Identify the Longest Movie


```sql
SELECT *
FROM netflix
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC
LIMIT 1;
```

**Objective:** Find the longest movie.

### 9. Find Content Added in the Last 5 Years


```sql
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';
```

**Objective:** Retrieve recently added content.

### 10. Find All Movies/TV Shows By Director 'Rajiv Chilaka'
 
```sql
SELECT *
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';
```

**Objective:** List content by specific director.

### 11. List All TV Shows with More Than 5 Seasons

```sql
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;
```

**Objective:** Identify long-running TV shows.

### 12. Count the Number of Content Items in Each Genre

```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY genre;
```

**Objective:** Count content by genre.

### 13.List All Movies That Are Documentaries

```sql
SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';
```

**Objective:** Retrieve documentaries.

### 14. 14. Find All Content Without a Director

```sql
SELECT * 
FROM netflix
WHERE director IS NULL;
```

**Objective:** Identify content missing director data.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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
GROUP BY category, TYPE
ORDER BY TYPE;
```

**Objective:** Label content as 'Bad' or 'Good' based on description keywords.

## Findings and Conclusion

-**Content Categorization**: Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.
- **Common Ratings**: Insights into the most common ratings provide an understanding of the content's target audience.
- Frequent German actors and their filmography are identified.
- **Geographical Insights**: The top countries and the average content releases by Germany highlight regional content distribution.

This analysis provides strategic insights for content planning and recommendation on Netflix.
