--customer journey
use PortfolioProject_MarketingAnalytics

select * from [dbo].[customer_journey];

-- identify duplicate values, count total duplicate rows using CTE

WITH DuplicateRecords AS (
    SELECT 
        JourneyID,
        CustomerID,
        ProductID,
        Stage,
        VisitDate,
        Action,
        Duration,
        ROW_NUMBER() OVER (
            PARTITION BY CustomerID, ProductID, VisitDate, Stage, Duration
            ORDER BY JourneyID
        ) AS row_num
    FROM [dbo].[customer_journey]
)

SELECT *
FROM DuplicateRecords
WHERE row_num > 1
ORDER BY JourneyID;


-- to clean the duplicate records and fill Null with Avg duration

select *  from [dbo].[customer_journey]


-- subquery to create avg of duration and to group columns to identify duplications
select journeyID,CustomerID, ProductID, VisitDate,Stage,Action, coalesce(Duration, Avg_duration) as Duration
from (
select journeyID, 
customerID,
ProductID, 
upper(Stage) as Stage,
Duration,
VisitDate,
Action,
AVG(Duration) over(Partition by VisitDate) as Avg_duration,
ROW_NUMBER() over ( partition by customerID, productID, Stage, VisitDate
order by journeyID -- to keep first occurance of duplicate
) as row_num -- assign unique no to each row which is unique
from [dbo].[customer_journey] ) as sub_query
where row_num = 1;