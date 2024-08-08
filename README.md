# AdventureWorks Sales Analysis with Advanced SQL, Python for Automating Data Import into MySQL Database, and Excel for Data Visualization and Reporting

## Objective
The purpose of this advanced SQL, Python, and Excel project was to conduct an in-depth analysis of AdventureWorks bike sales data to gain valuable insights into sales performance by country, customer segments, and products by answering 10 questions. Furthermore, the analysis aimed to identify trends and offer recommendations to inform data-driven business strategies for improved decision-making.

## Data Source and Overview
The AdventureWorks Raw Data csv files (excluding three duplicate files in the Sales Data folder and Product Category Sales (Unpivot Demo) file) used for this analysis were downloaded from [Kaggle](https://www.kaggle.com/datasets/deepujawarkar/adventure-works-raw-data). The ten datasets used include sales transaction details, product details, returns information, territories and customer demographics, which are essential for sales analysis.  

## Project Requirements
The task was to answer 10 questions and produce a report in a spreadsheet (Microsoft Excel or Google Sheets) displaying visualizations and insights gleaned. Pivot Tables were used to summarize data for visualizations. Find the questions below:

  1.	What was each country’s sales by customer age group?
  2.	Show the quantity of product subcategory purchases by customer age group.
  3.	Management is interested in comparing European market sales in the year 2021. Show a comparison of monthly sales for European countries in the year under review.
  4.	Compare monthly sales and cumulative sales in Australia and USA for the year 2021.
  5.	What was the quantity and value of returns for product categories in each country? 
  6.	What was the impact of returns on accessories, bikes and clothing sales in Canada?
  7.	Management is considering running a promotion on bikes to maximize revenue during the upcoming city bike tour season. Show current and new       prices of bikes if a 15% discount is applied.
  8.	Using CustomerKey, fetch the sales value of each customer's first purchase item and last purchase item? Indicate the difference between the   last and first purchase values and show results for the top 1,000 customers.
  9.	Show the number of bike purchases by Income.
  10.	Compare number of bike purchases for customers with children and customers without children in 2020.

## Automating Data Import into MySQL Database with Python
I created a new database named adventureworks2022 in MySQL Workbench using the following SQL commands:

    DROP DATABASE IF EXISTS adventureworks2022;
    CREATE DATABASE IF NOT EXISTS adventureworks2022 DEFAULT CHARACTER SET latin1;

There are several options for populating a database with data from csv files. I used the Spyder IDE in Anaconda Navigator to write a Python script that automated the import of all ten csv files into the adventureworks2022 database in MySQL. This process was completed once and can be used to import hundreds of files from a folder/directory into a database. Otherwise, the csv files would have to be imported sequentially using the Table Data Import Wizard in MySQL Workbench. You can imagine how tedious it will be if you have to upload many files. Similarly, the Python script can be used to import data into PostgreSQL and other databases with a few modifications. Here is a link to the Python script in this GitHub repository: [Python to MySQL data import](mysql_data_import.py)

Kindly note that this project focused on demonstrating Data Query Language (DQL), using the SELECT statement to retrieve data from one or more tables. Therefore, I ignored creating tables with specified data types, attributes, and constraints. MySQL database used the default data types to complete the process. However, the default data types take up more storage space. 

## Data Wrangling and Analysis Process
I created a VIEW called sales_combined that appends all three sales tables. This avoids using a UNION JOIN whenever all sales tables must be combined for queries. After retrieving the query results for the first question, I discovered that the ages of customers ranged from 40 and 90, excluding customer age groups under 40.  That was not representative of real-world customer ages; therefore, I altered the BirthDate field by adding 18 years to each customer’s BirthDate. Customers were subsequently grouped into the following buckets: 

* a. Under 30 (representing customers under 30 years old)
* b. 30 – 39 (representing customers aged 30 to 39 years)
* c. 40 – 49 (representing customers aged 40 to 49 years)
* d. 50 – 59 (representing customers aged 50 to 59 years)
* e. Over 60 (representing customers aged 60 and over)

Customers’ ages were calculated by subtracting the OrderDate from their new BirthDate. The assumption was to obtain customers’ ages at the time of ordering. Secondly, I wanted the ages and age groupings to remain the same each time the code was executed. On the other hand, subtracting the current date from BirthDate using the CURDATE() function would cause the ages and age groups to vary each time the code was executed. This will distort the analysis and insights in the future, and that is not what we want. The analysis, visualizations, and insights must remain consistent at all times.

Regarding bike purchases by income, customers were grouped into the following buckets: 

* a. Under $50k (indicating annual income below $50,000) 
* b. $50k - $75k (indicating annual income between $50,000 and $75,000)
* c. $75k - $100k (indicating annual income between $75,000 and $100,000)
* d. Over $100k (indicating annual income above $100,000)

Similarly, customers with and without children were categorized as follows: 

* No_Children (represents customers without children)
* Has_Children (represents customers with children)

After running the queries, I copied each result set using the option Copy Row (with name, unquoted). Each result set was pasted into a Microsoft Excel worksheet within a single workbook. All of the results were displayed in a single column with comma-delimited values. The values were separated into different columns using Excel’s Text to Columns function from the Data Tools group. The TRIM() function was used to tidy up columns with preceding and trailing white spaces. Other functions used include CONCAT() and VALUE(). The data was then aggregated and summarized using Pivot Tables, and charts for visualizations. Insights were then drawn from the visualizations.

Finally, each sheet in the Excel workbook was beautifully designed. To make navigation easier, I added a table of contents sheet which includes hyperlinks to the other sheets.

## SQL Queries, Tools, and Skills Utilized
Various [SQL queries](adventureworks2022.sql) were used to perform the sales analysis effectively. These queries involved aggregating sales data, calculating key performance metrics such as revenue, sales growth, and grouping data based on dimensions such as time, region, or product category. The queries further facilitated the exploration of sales patterns, customer segments, and comparison of performance across countries. The following are the tools and skills used in SQL, Python, and Excel:

![screen shot of tools](https://github.com/Jay-Paints/AdventureWorks-Sales-Analysis-with-SQL-Python-and-Excel/assets/113263067/57e2e174-8af7-4b69-bf74-3ad72f0c13da)

## Charts and Insights 
All images of the Excel charts can be viewed in this repository here: [Excel charts](https://github.com/Jay-Paints/AdventureWorks-Sales-Analysis-with-SQL-Python-and-Excel/commit/4ac8a67b9c9e3cc82ab9dc919e1155186cf752cd). Download the [Excel file](adventureworks2022.xlsx) to read the full report. Below are insights generated from the analysis:

#### 1.	Country Sales by Customer Age Group
* Customers between the ages of 30-39 and 40-49 years recorded the highest sales in all countries from 2020 to 2022, accounting for 69% of total sales. 
* France had the highest sales by 30-39 years age group. 

#### 2.	Product Purchases by Customer Age Group - 2021
* Again, customers aged 30-39 and 40-49 years purchased the highest quantities of product by subcategories. They purchased a total quantity of 54,484 products out of 84,174, representing 65%.

#### 3.	Europe Sales – 2021
* Sales in France rose steadily throughout the year, with a significant spike from October to December, indicating a strong end-of-year performance.
* Similarly, Germany's sales remained relatively stable, with a notable surge in December. This depicts a steady market with a late-year boost.
* On the other hand, sales in the UK remained consistent, with a rise in July and significant growth beginning in September.
* Overall, all three countries saw growth near the end of the year, with France showing the greatest increase. It would be beneficial to correlate these trends with specific events or marketing initiatives, such as Christmas holidays or year-end promotions to gain deeper insights.

#### 4.	Sales and Cumulative Sales for Australia & USA - 2021
* Australia began the year with monthly sales double the amount of USA's sales until April 2021. Sales in the USA increased significantly in July and December.
* Australia's sales grew at a faster rate compared to USA in the first half of the year. USA's sales picked up from July, with a remarkable gain occurring in December. Overall, both countries experienced continuous increases in cumulative sales throughout 2021.
* The consistent growth in cumulative sales suggests a healthy market for both countries with potential for expansion. 

#### 5.	Product Returns by Country
*	USA had the highest number of Accessory returns, followed by Australia and Canada. Regarding Bike returns, the highest number was recorded by Australia.
*	In terms of value, Australia had the highest product returns value, followed by USA and Germany. Canada and France recorded the lowest return value.
*	There were no Component returns.

#### 6.	Canada Product Returns (Accessories, Bikes and Clothing)
*	Canada's sales revenue was reduced by 2.5%, that is, from $1.77 million to $1.72 million, due to returns in Accessories, Bikes, and Clothing. A total of $44,502 was lost to returns.

#### 7.	Bike Purchases by Customer Income
* As income rose, the number of bikes purchased declined.
* Customers earning less than $50,000 annually purchased the most bikes, closely followed by customers who earned between $50,000 and $75,000 as the second-highest purchasers.
* Customers who earned more than $100,000 yearly purchased the fewest bikes.
* As a result, promotional and marketing initiatives should target customers with an annual income of less than $100,000. 

#### 8.	Bike Sales - Customers with Children vs Customers without Children
* Monthly sales remained rather stable throughout the year, with a notable surge in December, as shown by the bars.
* The blue line indicates that the percentage of sales by customers with children remained relatively consistent. However, there was a considerable decrease in November.  This suggests that customers with children made fewer purchases in November.
* On the other hand, the yellow line shows that the percentage of purchases by customers without children increased significantly in November. Customers without children were more active in November. 

## Recommendations
#### 1. Promotional and marketing initiatives should target the following demographics:
* Customers aged 30 to 49 years old.
* Customers with an annual income of less than $100,000.
* Customers with children.
#### 2. Promotional Period
* Run promotions from September to December to maximize end-of-year sales revenue in Europe.
#### 3.	Market Expansion
* Consider expanding the market in Australia and the USA. There is potential for growth.
#### 4.	Product Returns
* Investigate and evaluate the quality of Accessories in the USA and Australia. 

## Conclusion
This in-depth AdventureWorks Data Analysis project demonstrates how SQL can be integrated with Python and Excel to facilitate automated data import, advanced SQL queries, and Excel visualizations to extract meaningful insights from large datasets. The approach provides a clear understanding of leveraging diverse tools to complete the data analysis project in a less laborious and timely manner.
