use campusx;
Drop table if exists sharktank;

CREATE TABLE sharktank (
    Season_Number INT,
    Startup_Name VARCHAR(255),
    Episode_Number INT,
    Pitch_Number INT,
    Season_Start VARCHAR(255),
    Season_End VARCHAR(255),
    Anchor VARCHAR(255),
    Industry VARCHAR(255),
    Business_Description VARCHAR(255),
    Started_in VARCHAR(255),
    Number_of_Presenters INT,
    Male_Presenters INT,
    Female_Presenters INT,
    Transgender_Presenters INT,
    Couple_Presenters INT,
    Pitchers_Average_Age VARCHAR(255),
    Pitchers_City VARCHAR(255),
    Pitchers_State VARCHAR(255),
    Yearly_Revenue_in_lakhs VARCHAR(255),
    Monthly_Sales_in_lakhs VARCHAR(255),
    Original_Ask_Amount FLOAT,
    Original_Offered_Equity_in FLOAT,
    Valuation_Requested_in_lakhs FLOAT,
    Received_Offer VARCHAR(255),
    Accepted_Offer VARCHAR(255),
    Total_Deal_Amount_in_lakhs FLOAT,
    Total_Deal_Equity FLOAT,
    Number_of_Sharks_in_Deal INT,
    Namita_Investment_Amount_in_lakhs FLOAT,
    Vineeta_Investment_Amount_in_lakhs FLOAT,
    Anupam_Investment_Amount_in_lakhs FLOAT,
    Aman_Investment_Amount_in_lakhs FLOAT,
    Peyush_Investment_Amount_in_lakhs FLOAT,
    Amit_Investment_Amount_in_lakhs FLOAT,
    Ashneer_Investment_Amount FLOAT,
    Namita_Present VARCHAR(255),
    Vineeta_Present VARCHAR(255),
    Anupam_Present VARCHAR(255),
    Aman_Present VARCHAR(255),
    Peyush_Present VARCHAR(255),
    Amit_Present VARCHAR(255),
    Ashneer_Present VARCHAR(255)
);

select * from sharktank;

/*
	 1 . You Team must promote shark Tank India season 4, The senior come up with the idea to show highest
	 funding domain wise so that new startups can be attracted, and you were assigned the task to show the same.
*/ 
-- Approch 1:
select Industry , max(Total_Deal_Amount_in_lakhs) as 'highest funding' from sharktank
group by Industry;

-- Approch 2:
select Industry,Total_Deal_Amount_in_lakhs as 'highest funding' from (
	select Industry,Total_Deal_Amount_in_lakhs,
	row_number() over(partition by Industry order by Total_Deal_Amount_in_lakhs desc) as 'rnk'
	from sharktank
	group by Industry,Total_Deal_Amount_in_lakhs
) t where rnk = 1;

/*
  2. You have been assigned the role of finding the domain where female as pitchers have
     female to male pitcher ratio >70%
*/
select*,(female/male)*100 as 'pitcher_ratio' from
(
	select Industry , sum(Female_Presenters) as 'female',
	sum(Male_Presenters) as 'male' from sharktank
	group by Industry
	having sum(Male_Presenters) > 0 and sum(Female_Presenters) > 0
) k
where (female/male)*100  > 70 ;

/*
	 3.You are working at marketing firm of Shark Tank India, you have got the task to determine
	 volume of per season sale pitch made, pitches who received offer and pitches that were converted.
	 Also show the percentage of pitches converted and percentage of pitches entertained.
*/

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

/*
	4.	As a venture capital firm specializing in investing in startups featured on a renowned
	 entrepreneurship TV show, you are determining the season with the highest average monthly
	 sales and identify the top 5 industries with the highest average monthly sales during that season
	 to optimize investment decisions?
*/

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

/*
	5.	As a data scientist at our firm, your role involves solving real-world challenges like identifying
	 industries with consistent increases in funds raised over multiple seasons. This requires focusing on
	 industries where data is available across all three seasons. Once these industries are pinpointed, 
	 your task is to delve into the specifics, analyzing the number of pitches made, offers received, 
	 and offers converted per season within each industry.
*/

-- step 1
select industry ,season_number , sum(total_deal_amount_in_lakhs) from sharktank group by industry ,season_number;

-- step 2
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


/*
	6.	Every shark wants to know in how much year their investment will be returned, so you must create a system for them,
	 where shark will enter the name of the startup’s and the based on the total deal and equity given in how many years their 
	 principal amount will be returned and make their investment decisions.
*/

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
call turn_around_time('BoozScooters');
select * from sharktank;

/*
 7. In the world of startup investing, we're curious to know which big-name investor, often referred to as "sharks," tends to put the most
    money into each deal on average. This comparison helps us see who's the most generous with their investments and
    how they measure up against their fellow investors.
*/

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

/*
-- 8. Develop a system that accepts inputs for the season number and the name of a shark. The procedure will then provide detailed insights into the total investment made by 
-- that specific shark across different industries during the specified season. Additionally, it will calculate the percentage of their investment in each sector relative to
-- the total investment in that year, giving a comprehensive understanding of the shark's investment distribution and impact.
*/

select * from sharktank

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

call getseasoninvestment(2, 'Anupam');

drop procedure getseasoninvestment; 

 set @total = (select  sum(Total_Deal_Amount_in_lakhs) from sharktank where Season_Number= 1 );
select @total
-- step 1  -- simple procedure to show output , 
-- step 2 -- industry specific 
-- step 3 -- give output 
-- step 4 -- with total

/*
-- 9. In the realm of venture capital, we're exploring which shark possesses the most diversified investment portfolio across various industries. 
-- By examining their investment patterns and preferences, we aim to uncover any discernible trends or strategies that may shed light on their decision-making
-- processes and investment philosophies.

*/

select sharkname, 
count(distinct industry) as 'unique industy',
count(distinct concat(pitchers_city,' ,', pitchers_state)) as 'unique locations' from 
(
		SELECT Industry, Pitchers_City, Pitchers_State, 'Namita'  as sharkname from sharktank where  `Namita_Investment_Amount_in_lakhs` > 0
		union all
		SELECT Industry, Pitchers_City, Pitchers_State, 'Vineeta'  as sharkname from sharktank where `Vineeta_Investment_Amount_in_lakhs` > 0
		union all
		SELECT Industry, Pitchers_City, Pitchers_State, 'Anupam'  as sharkname from sharktank where  `Anupam_Investment_Amount_in_lakhs` > 0 
		union all
		SELECT Industry, Pitchers_City, Pitchers_State, 'Aman'  as sharkname from sharktank where `Aman_Investment_Amount_in_lakhs` > 0
		union all
		SELECT Industry, Pitchers_City, Pitchers_State, 'Peyush'  as sharkname from sharktank where   `Peyush_Investment_Amount_in_lakhs` > 0
		union all
		SELECT Industry, Pitchers_City, Pitchers_State, 'Amit'  as sharkname from sharktank where `Amit_Investment_Amount_in_lakhs` > 0
		union all
		SELECT Industry, Pitchers_City, Pitchers_State, 'Anupam'  as sharkname from sharktank where  `Ashneer_Investment_Amount` > 0 
		union all
		SELECT Industry, Pitchers_City, Pitchers_State, 'Ashneer'  as sharkname from sharktank where `Ashneer_Investment_Amount` > 0
)t  
group by sharkname 
order by  'unique industry' desc ,'unique location' desc;