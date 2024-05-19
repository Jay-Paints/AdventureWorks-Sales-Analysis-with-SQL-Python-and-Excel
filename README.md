# AdventureWorks Sales Analytics with Advanced SQL Queries, Python for automating data import into MySQL database and Excel for data visualization and reporting

## Objective
The aim of this advanced SQL, Python and Excel project is to answer 10 questions by conducting an in-depth analysis of AdventureWorks bike sales data to gain valuable insights in sales performance by country, customer segments and products. Additionally, the analysis is geared towards identifying trends to inform data-driven business strategies for improved decision-making. 

## Data Source and Overview
The AdventureWorks Raw Data csv files used for the analysis were downloaded from Kaggle (excluding three duplicate files in the Sales Data folder and Product Category Sales (Unpivot Demo) file). The ten datasets used encompass sales transactional information, product details, returns details, territories and customer demographics, essential for sales analysis. Here is the link to download the files: https://www.kaggle.com/datasets/deepujawarkar/adventure-works-raw-data  

## Project Requirements
The task is to answer 10 questions and produce a report in a spreadsheet (Microsoft Excel or Google Sheets) displaying visualizations and insights gleaned. Pivot Tables were used to summarize data for visualizations. Find the questions below:

  1.	What was each country’s sales by customer age group?
  2.	Show the quantity of product subcategory purchases by customer age group.
  3.	Management is interested in comparing European market sales in the year 2021. Show monthly sales compared for European countries in the      year under review.
  4.	Compare monthly sales and cumulative sales for Australia and USA for the year 2021.
  5.	What was the quantity and value of returns for product categories in each Country? 
  6.	What was the impact of returns on accessories, bikes and clothing sales in Canada?
  7.	Management is considering running a promotion on bikes to maximize revenue in the upcoming city bike tour season. Show current and new       prices of bikes if 15% discount is applied.
  8.	Using CustomerKey fetch the sales value of each customer's first purchase item and last purchase item? Indicate the difference between the   last and first purchase values and show results for first 1,000 customers.
  9.	Show the number of bike purchases by Income.
  10.	Compare number of bike purchases for customers with children and customers with no children in 2020.

## Automating Data Import into MySQL Database with Python
I created a new database named adventureworks2022 in MySQL Workbench using the following SQL commands:

    DROP DATABASE IF EXISTS adventureworks2022;
    CREATE DATABASE IF NOT EXISTS adventureworks2022 DEFAULT CHARACTER SET latin1;

There are a few options to populate a database with data from csv files. I created a Python script using Spyder IDE in Anaconda Navigator to automate importing all ten csv files into adventureworks2022 database in MySQL. This process was done only once and can be used to import hundreds of files in a folder/directory into a database. Otherwise, the csv files would have to be imported one after the other using the Table Data Import Wizard in MySQL Workbench. You can imagine how tedious this will be if you are to upload a large number of files. Similarly, the Python script can be used to import data into PostgreSQL and other databases with a few modifications. The python script and data import images are shared in this repository.

## Data Preprocessing and Analysis Process
I created a VIEW as sales_combined to append all three sales tables. This avoids using a UNION JOIN anytime all sales tables are to be consolidated for queries. Upon fetching query results for the first question, I realized the ages of customers were between 40 and 90, which excluded customer age groups under 40.  That was not representative of real-world customer ages; therefore, I altered the BirthDate column by adding 18 years to each customer’s BirthDate. Subsequently, customers were grouped into the following bins: 

* a. Under 30 (representing customers below 30 years)
* b. 30 – 39 (representing customers from 30 and 39 years)
* c. 40 – 49 (representing customers from 40 and 49 years)
* d. 50 – 59 (representing customers from 50 and 59 years)
* e. Over 60 (representing customers from 60 years and over)

Age of customers were calculated by subtracting OrderDate from the new BirthDate. The assumption was to get customers’ age at the time they ordered. Secondly, I wanted the ages and age groups to remain the same every time the code is run. On the other hand, subtracting the current date, using the CURDATE() function, from BirthDate would change the ages and age groups whenever the code is run. This will distort the analysis and insights in future and that is not what we want. The analysis, visualizations and insights must remain the same at all times.

Regarding bike purchases by income, customers were grouped into the following buckets: 

* Under $50k (representing annual income below $50,000) 
* $50k - $75k (representing annual income between $50,000 and $75,000)
* $75k - $100k (representing annual income between $75,000 and $100,000)
* Over $100k (representing annual income above $100,000)

Similarly, customers with and without children were grouped as follows: 

* No_Children (representing customers without children)
* Has_Children (representing customers with children)

After running the queries, I copied each result set using the option Copy Row (with name, unquoted). Each result set was pasted in a Microsoft Excel worksheet, in one workbook. All results displayed as comma delimited values in one column. The Text to Columns feature in the Data Tools group in Excel was used to split the values into separate columns. Columns that had preceding and trailing white spaces were cleaned with the TRIM() function. Other functions used include CONCAT() and VALUE(). Thereafter, Pivot Tables were used to aggregate and summarize data for visualization. Insights were then drawn from the visualizations. 

Finally, all sheets in the Excel workbook were beautifully designed. A table of contents sheet that contains hyperlinks to each sheet was added to make navigation easier. 

## SQL Queries, Tools and Skills Utilized
Various SQL queries were used to perform the sales analysis effectively. These queries involve aggregating sales data, calculating key performance metrics such as revenue, sales growth, and grouping data based on dimensions such as time, region, or product category. The queries further facilitated the exploration of sales patterns, customer segmentation, and comparison of performance by country. Below are the tools and skills utilized in SQL, Python and Excel:

![screen shot of tools](https://github.com/Jay-Paints/AdventureWorks-Sales-Analysis-with-SQL-Python-and-Excel/assets/113263067/57e2e174-8af7-4b69-bf74-3ad72f0c13da)

## Charts and Insights 
Images of the Excel charts are in this repository. Download the Excel file for the full report. Below are insights generated from the analysis: 

#### 1.	Country Sales by Customer Age Group
*	In all countries, customers between the ages of 30-39 and 40-49 years recorded the highest sales, making 69% of total sales from 2020-2022. 
*	France recorded the highest sales by 30-39 years age group. 

#### 2.	Product Purchases by Customer Age Group - 2021
*	Again, the highest quantities of product subcategories were purchased by customers between the ages of 30-39 and 40-49. They purchased a total quantity of 54,484 products out of 84,174, representing 65%.  

#### 3.	Europe Sales – 2021
*	Sales for France showed a steady increase throughout the year with significant spike from October to December, indicating a strong end-of-year performance.
*	Similarly, Germany's sales remained relatively stable with a significant spike in December. This depicts a steady market with a late-year boost.
*	On the other hand, UK experienced steady sales with a spike in July and significant growth from September onwards.
*	Overall, all three countries experienced growth towards the end of the year, with France showing the most significant increase. It would be beneficial to correlate these trends with specific events or marketing efforts such as Christmas holidays or year-end promotions respectively, in order to gain deeper insights.

#### 4.	Sales and Cumulative Sales for Australia & USA - 2021
*	Australia begun the year with monthly sales double the amount of USA's sales until April 2021. USA sales saw a significant spike in July and December.
*	Cumulatively, Australia's sales grew at a faster rate compared to USA in the first half of the year. USA's sales picked up from July to November and experienced the highest growth in December. Overall, both countries showed consistent increase in cumulative sales throughout 2021. 
*	The steady growth in cumulative sales suggests a healthy market for both countries with potential for expansion. 

#### 5.	Product Returns by Country
*	USA recorded the highest number of Accessory returns, followed by Australia and Canada. Regarding Bike returns, the highest number was recorded by Australia. 
*	In terms of value, Australia recorded the biggest returns value, followed by USA and Germany. The lowest returns value was recorded by Canada and France.
*	There were no Component returns.

#### 6.	Canada Product Returns (Accessories, Bikes and Clothing)
*	Canada's sales revenue reduced by 2.5%, that is from $1.77M to $1.72M, due to returns in Accessories, Bikes and Clothing. A total of $44,502 was lost to returns.

#### 7.	Bike Purchases by Customer Income
*	As income increased, the number of bikes purchased decreased. 
*	Customers who earned less than $50,000 annually purchased the highest number of bikes, closely followed by customers who earned between $50,000 and $75,000 as second highest purchasers. 
*	High income earners, that is customers whose income were above $100,000 annually, purchased the least number of bikes. 
*	Consequently, promotions and marketing campaigns should target customers whose annual income fall below $100,000. 

#### 8.	Bike Sales - Customers with Children vs Customers without Children
*	Monthly sales were fairly consistent throughout the year, with a noticeable increase in December, as depicted by the bars. 
*	The blue line shows the percentage of sales by customers with children was relatively stable. However, there was a significant drop in November.  This suggests that customers with children were less active in purchasing during this month. 
*	On the other hand, the yellow line indicates the percentage of sales by customers without children saw a significant increase in November.

## Conclusion
This in-depth AdventureWorks Data Analysis project showcases how SQL can be combined with Python and Excel to facilitate automated data import, advanced SQL queries and Excel visualizations to extract meaningful insights from complex datasets. The approach provides a clear understanding of leveraging diverse tools to complete the data analysis project in a less laborious and timely manner.
