# 🦈 Shark Tank India SQL Analysis

This project is a SQL case study based on the Indian version of the popular business reality show **Shark Tank**. Using a cleaned dataset of pitches and investments from the show, we performed in-depth SQL analysis to answer critical business questions.

## 📌 Project Objective

The goal of this project is to practice and demonstrate SQL skills by solving real-world business questions using a cleaned dataset derived from Shark Tank India.

We cover:
- Data exploration
- Investment trend analysis
- Shark-wise deal breakdowns
- Equity-debt deal insights
- Domain-wise funding evaluations

## 🗂 Dataset

- **File**: `sharktank_cleaned.csv`
- **Size**: ~142 records
- **Source**: Manually cleaned data compiled from public information
- **Fields include**: `pitcher`, `brand_name`, `industry`, `deal`, `investment_received`, `equity`, `ask_amount`, `ask_equity`, `deal_type`, `shark_names`, etc.

## 📘 Problem Statement

A total of **20+ business questions** were framed around this dataset, such as:

- How many total pitchers appeared on the show?
- Which industries received the highest number of deals?
- Which sharks invested the most?
- What kind of deals (equity, debt, mix) were most common?
- Average equity dilution across all deals?
- Patterns of solo vs group investments?

The full list of questions is available in [`CampusX SQL Question.docx`](CampusX%20SQL%20Question.docx).

## 🛠 Tools & Technologies

- **SQL**: Core analysis and querying
- **MySQL/PostgreSQL (preferred)**: Executed and tested queries
- **Excel**: Data pre-cleaning
- **Git/GitHub**: Version control and collaboration

## 📄 Solution

The answers to all questions are provided in the [`Solution.sql`](Solution.sql) file. Each query is commented and numbered to match the original problem statement for easy traceability.

### Example Query

```sql
-- Q4: What is the average equity taken by sharks?
SELECT ROUND(AVG(equity), 2) AS avg_equity_percent
FROM sharktank_cleaned
WHERE deal != 'No Deal';
