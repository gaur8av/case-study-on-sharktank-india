
# 🦈 Shark Tank India SQL Analysis

## Project Overview

This project presents a complete SQL-based analysis of startup investment data from **Shark Tank India**. Business scenarios were framed around funding trends, investor behavior, pitch success rates, and industry growth patterns — all solved with structured SQL queries using a cleaned dataset.

![Shark Tank](https://cdn-icons-png.flaticon.com/512/833/833314.png)

---

## Objectives

1. Import and explore structured startup funding data.
2. Solve real-world business problems using SQL.
3. Analyze investment behavior of individual sharks.
4. Generate investor-focused metrics like ROI and deal diversity.
5. Deliver actionable insights to help optimize funding and marketing decisions.

---

## 📥 Dataset Import

```sql
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sharktank_cleaned.csv'
INTO TABLE campusx.sharktank
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
```

---

## Business Tasks & SQL Solutions

---

### 🧠 Task 1: Promote Season 4 by showcasing the highest funding domain-wise.

```sql
select Industry , max(Total_Deal_Amount_in_lakhs) as 'highest funding' from sharktank
group by Industry;
```

---

### 🧠 Task 2: Identify domains where female-to-male pitcher ratio >70%.

```sql
select*,(female/male)*100 as 'pitcher_ratio' from
(
	select Industry , sum(Female_Presenters) as 'female',
	sum(Male_Presenters) as 'male' from sharktank
	group by Industry
	having sum(Male_Presenters) > 0 and sum(Female_Presenters) > 0
) k
where (female/male)*100  > 70 ;
```

---

### 🧠 Task 3: Show volume of pitches, offers, conversions per season.

```sql
select  a.Season_Number, total, received_offer_total, (received_offer_total/total)*100 as 'received %',
accepted_offer_total , (accepted_offer_total / total) * 100 as 'accepted %'from(
	select Season_Number,count(Startup_Name) as 'total' from
	sharktank group by Season_Number
) a
inner join
(
	select Season_Number,count(Startup_Name) as 'received_offer_total' from sharktank
	where Received_Offer = 'Yes' group by Season_Number
) b
on a.Season_Number = b.Season_Number
inner join(
	select Season_Number,count(Startup_Name) as 'accepted_offer_total' from sharktank
	where Accepted_Offer = 'Yes' group by Season_Number
) c
on b.Season_Number = c.Season_Number;
```

---

### 🧠 Task 4: Find the season with the highest average monthly sales and top 5 industries.

```sql
set @highest_avg_m_sales_season = (select Season_Number from(
	select Season_Number , Round(avg(Monthly_Sales_in_lakhs),2) as 'avg_mon_sales_by_season' from
	sharktank group by Season_Number
	order by Round(avg(Monthly_Sales_in_lakhs),2) desc limit 1
) m );

select Industry , Round(avg(Monthly_Sales_in_lakhs),2) as 'avg_mon_sales'
from sharktank
where Season_Number = @highest_avg_m_sales_season
group by Industrygenre_preferences
order by Round(avg(Monthly_Sales_in_lakhs),2)  desc limit 5;
```

---

### 🧠 Task 5: Identify industries with consistent funding growth across all seasons.

```sql
WITH ValidIndustries AS (
    SELECT 
        industry, 
        MAX(CASE WHEN season_number = 1 THEN total_deal_amount_in_lakhs END) AS season_1,
        MAX(CASE WHEN season_number = 2 THEN total_deal_amount_in_lakhs END) AS season_2,
        MAX(CASE WHEN season_number = 3 THEN total_deal_amount_in_lakhs END) AS season_3
    FROM sharktank 
    GROUP BY industry 
    HAVING season_3 > season_2 AND season_2 > season_1 AND season_1 != 0
)  

SELECT 
    t.season_number,
    t.industry,
    COUNT(t.startup_Name) AS Total,
    COUNT(CASE WHEN t.received_offer = 'Yes' THEN t.startup_Name END) AS Received,
    COUNT(CASE WHEN t.accepted_offer = 'Yes' THEN t.startup_Name END) AS Accepted
FROM sharktank AS t
JOIN ValidIndustries AS v ON t.industry = v.industry
GROUP BY t.season_number, t.industry;  
```

---

### 🧠 Task 6: Create a system for sharks to calculate ROI time.

```sql
DELIMITER //
CREATE PROCEDURE turn_around_time(IN startup VARCHAR(100))
BEGIN
    DECLARE offer_status VARCHAR(10);
    DECLARE revenue_info VARCHAR(50);

    -- Get the status and revenue
    SELECT Accepted_Offer, Yearly_Revenue_in_lakhs
    INTO offer_status, revenue_info
    FROM sharktank
    WHERE Startup_Name = startup
    LIMIT 1;

    -- Logic to handle different cases
    IF offer_status = 'No' THEN
        SELECT 'Turnaround time cannot be calculated as startup didn’t accept the offer' AS message;

    ELSEIF revenue_info = 'Not Mentioned' and offer_status = 'Yes'  THEN
        SELECT 'Turnaround time cannot be calculated as past data not available' AS message;

    ELSE
        SELECT 
            Startup_Name,
            Yearly_Revenue_in_lakhs,
            Total_Deal_Amount_in_lakhs,
            Total_Deal_Equity,
            ROUND(
                Total_Deal_Amount_in_lakhs / (Yearly_Revenue_in_lakhs * (Total_Deal_Equity / 100.0)),
                2
            ) AS ROI_Time_in_Years
        FROM sharktank
        WHERE Startup_Name = startup;
    END IF;

END;
//
DELIMITER ;

CALL turn_around_time('BoozScooters');
```

---

### 🧠 Task 7: Identify the most generous shark by average deal size.

```sql
select sharkname , avg(investment) as 'average' from
(
	SELECT `Namita_Investment_Amount_in_lakhs` AS investment, 'Namita' AS sharkname FROM sharktank WHERE `Namita_Investment_Amount_in_lakhs` > 0
	union all
	SELECT `Vineeta_Investment_Amount_in_lakhs` AS investment, 'Vineeta' AS sharkname FROM sharktank WHERE `Vineeta_Investment_Amount_in_lakhs` > 0
	union all
	SELECT `Anupam_Investment_Amount_in_lakhs` AS investment, 'Anupam' AS sharkname FROM sharktank WHERE `Anupam_Investment_Amount_in_lakhs` > 0
	union all
	SELECT `Aman_Investment_Amount_in_lakhs` AS investment, 'Aman' AS sharkname FROM sharktank WHERE `Aman_Investment_Amount_in_lakhs` > 0
	union all
	SELECT `Peyush_Investment_Amount_in_lakhs` AS investment, 'peyush' AS sharkname FROM sharktank WHERE `Peyush_Investment_Amount_in_lakhs` > 0
	union all
	SELECT `Amit_Investment_Amount_in_lakhs` AS investment, 'Amit' AS sharkname FROM sharktank WHERE `Amit_Investment_Amount_in_lakhs` > 0
	union all
	SELECT `Ashneer_Investment_Amount` AS investment, 'Ashneer' AS sharkname FROM sharktank WHERE `Ashneer_Investment_Amount` > 0
) k group by sharkname;
```

---

### 🧠 Task 8: Stored procedure to get shark's industry-wise investment by season.

```sql
DELIMITER //
create PROCEDURE getseasoninvestment(IN season INT, IN sharkname VARCHAR(100))
BEGIN
    CASE 
        WHEN sharkname = 'namita' THEN
            set @total = (select  sum(`Namita_Investment_Amount_in_lakhs`) from sharktank where Season_Number= season );
            SELECT Industry, sum(`Namita_Investment_Amount_in_lakhs`) as 'sum' ,(sum(`Namita_Investment_Amount_in_lakhs`)/@total)*100 as 'Percent_namita' FROM sharktank WHERE season_Number = season AND `Namita_Investment_Amount_in lakhs_` > 0
            group by industry;
        WHEN sharkname = 'Vineeta' THEN
            set @total = (select  sum(`Vineeta_Investment_Amount_in_lakhs`) from sharktank where Season_Number= season );
            SELECT industry,sum(`Vineeta_Investment_Amount_in_lakhs`) as 'sum' , (sum(`Vineeta_Investment_Amount_in_lakhs`)/@total)*100 as 'Percent_vineeta' FROM sharktank WHERE season_Number = season AND `Vineeta_Investment_Amount_in_lakhs` > 0
            group by industry;
        WHEN sharkname = 'Anupam' THEN
            set @total = (select  sum(`Anupam_Investment_Amount_in_lakhs`) from sharktank where Season_Number= season );
            SELECT industry , sum(`Anupam_Investment_Amount_in_lakhs`) as 'sum' , (sum(`Anupam_Investment_Amount_in_lakhs`)/@total)*100 as 'Percent_anupam'  FROM sharktank WHERE season_Number = season AND `Anupam_Investment_Amount_in_lakhs` > 0
            group by Industry;
        WHEN sharkname = 'Aman' THEN
            SELECT industry,sum(`Aman_Investment_Amount_in_lakhs`) as 'sum'  FROM sharktank WHERE season_Number = season AND `Aman_Investment_Amount_in_lakhs` > 0
             group by Industry;
        WHEN sharkname = 'Peyush' THEN
             SELECT industry,sum(`Peyush_Investment_Amount_in_lakhs`) as 'sum'  FROM sharktank WHERE season_Number = season AND `Peyush_Investment_Amount_in_lakhs` > 0
             group by Industry;
        WHEN sharkname = 'Amit' THEN
              SELECT industry,sum(`Amit_Investment_Amount_in_lakhs`) as 'sum'   WHERE season_Number = season AND `Amit_Investment_Amount_in_lakhs` > 0
             group by Industry;
        WHEN sharkname = 'Ashneer' THEN
            SELECT industry,sum(`Ashneer_Investment_Amount`)  FROM sharktank WHERE season_Number = season AND `Ashneer_Investment_Amount` > 0
             group by Industry;
        ELSE
            SELECT 'Invalid shark name';
    END CASE;
END //
DELIMITER ;


CALL getseasoninvestment(2, 'Anupam');
```

---

### 🧠 Task 9: Find the shark with the most diversified portfolio.

```sql
select sharkname, 
count(distinct industry) as 'unique industy',
count(distinct concat(pitchers_city,' ,', pitchers_state)) as 'unique locations' from 
(
	-- union all block for all sharks
)t  
group by sharkname 
order by  'unique industry' desc ,'unique location' desc;
```

---

## 📁 Files in the Repository

| File Name | Description |
|-----------|-------------|
| `sharktank_cleaned.csv` | Cleaned dataset from Shark Tank India |
| `Solution.sql` | Full set of SQL solutions |
| `CampusX SQL Question.docx` | Detailed business problem statements |
| `README.md` | Project documentation |

---

## 🚀 How to Use

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/sharktank-sql-analysis.git
   ```

2. Load `sharktank_cleaned.csv` into MySQL.

3. Execute `Solution.sql` to reproduce all results.

---

## 📬 Contact

- [LinkedIn](https://www.linkedin.com/in/your-profile)
- [GitHub](https://github.com/yourusername)

---

⭐ Star this repo if you found it helpful!
