# Sizwe-s_Coffee-Pty-Data_analytics_assignment_2
This project applies SQL-based data analysis to Sizwe Coffee's operational and financial data, investigating revenue performance, profit drivers, customer behaviour, collections efficiency, promotional support, sales representative effectiveness, and margin trends across specified financial years..
Sizwe Coffee SQL Business Analysis
Project Overview

This project analyses operational and financial data for Sizwe Coffee (Pty) Ltd, a South African coffee roastery and wholesale supplier with distribution centres in Johannesburg and Cape Town. The analysis was conducted to support the company's FY2025 year-end review and address business questions raised by the Financial Director, Nomsa Dlamini, and the National Sales Manager, Bongani Twala.

Using SQL and Databricks, the project examines business performance across the period 1 July 2023 to 30 June 2025, focusing on revenue growth, profitability, customer performance, collections, promotional activity, sales representative effectiveness, seasonality, and margin trends.

📌 The analysis answers the following eight business questions:

How did revenue perform across sales channels in FY2024 and FY2025?

Which product lines generate the most profit and the highest margins?

How effectively are customer invoices being collected?

Who are the top ten customers by FY2025 revenue?

Which high-value wholesale customers have never received trade promotions?

Are sales representatives achieving their monthly revenue targets?

What seasonal trends exist in revenue across the two-year period?

What factors contributed to the decline in gross margin from FY2024 to FY2025?

📌The analysis uses the following tables:

<img width="797" height="502" alt="image" src="https://github.com/user-attachments/assets/672606c3-4d8e-4aee-88db-93cce92e1fb6" />

📌 Skills Demonstrated
The project applies a range of SQL techniques to solve business problems and generate actionable insights.

SQL Technique	→ Business Application

INNER JOIN - Integrates customer, order, sales, and product data

LEFT JOIN	- Retains customers or sales representatives without matching records

CASE Expressions - Calculates revenue, profitability, and invoice metrics

Aggregate Functions - (SUM, AVG, COUNT)	Classifies financial years and performs conditional calculations

Common Table Expressions - (CTEs)	Streamlines complex, multi-step calculations

Window Functions - Calculates month-over-month growth and rolling averages

Ranking and Sorting - Identifies leading customers and sales representatives

NULL Handling - Prevents inaccurate calculations and divide-by-zero errors

Date Functions - Analyzes financial years and monthly trends

📌 Key insights:

The business continues to deliver strong year-on-year growth, supported by solid sales execution and predictable seasonal demand patterns. However, growth is increasingly concentrated in specific channels and product categories, creating both profitability and cash-flow risks. The greatest opportunities lie in improving collections management, refining the sales mix, and strengthening commercial engagement with key wholesale customers.

Revenue Growth and Channel Performance

Revenue growth remains healthy, with both Wholesale and Subscription channels achieving approximately 8.8% year-on-year growth. Despite similar growth rates, Wholesale remains the dominant channel, generating roughly 2.3 times more revenue than Subscription. This highlights the business's heavy reliance on Wholesale as its primary source of revenue and future growth.

Profitability Driven by Product Mix

Profitability is influenced not only by sales volume but also by product mix. House Blend generates the highest gross profit in absolute terms.
Single Origin delivers the highest gross margin percentage. This demonstrates that the most profitable product on a margin basis is not necessarily the largest contributor to overall profit. Product volume and sales mix remain critical drivers of total profitability.

Collections and Cash-Flow Risk

One of the most significant operational concerns is the concentration of unpaid invoices within the Wholesale channel.

Key findings include:

Wholesale accounts for nearly all of the ~R88.6 million outstanding balance.
Average payment settlement in Wholesale is 68.7 days, compared with only 3.8 days in Subscription.

These figures indicate a clear credit control weakness and create a meaningful cash-flow risk despite strong revenue growth. Reducing overdue balances and improving payment collection discipline should be a strategic priority.

Customer Concentration and Commercial Opportunities

Customer revenue is concentrated among a small number of large accounts.

Halvane Retail Group is the largest customer in FY2025 by revenue.
Major Wholesale customers including Umhlanga Fresh, Ridgeway Foods, and Kalahari Kitchen generate substantial revenue but have not received trade promotion support.

These accounts represent potential opportunities for targeted commercial initiatives, such as rebates, promotional funding, or listing support, which could strengthen relationships and unlock additional growth.

Sales Team Performance

Sales execution is a clear strength of the business.
16 out of 18 sales representatives exceeded 100% of their monthly targets.
Several representatives achieved more than 220% of target, demonstrating exceptional performance.
Overall, the sales team is consistently outperforming expectations and contributing strongly to revenue growth.

Seasonal Demand Patterns

The business exhibits a highly predictable seasonal sales cycle. Sales typically increase from January through June. Sales decline from July through December.
June is consistently the strongest month and December is consistently the weakest month. The repeatability of this pattern provides a valuable advantage for forecasting, inventory planning, staffing, and cash-flow management.

Margin Decline Explained

The decline in overall margin is not being driven by deteriorating profitability within individual product lines. In fact, margins across product categories have remained stable or improved slightly. The primary issue is a shift in revenue mix toward Bulk Commercial products, which carry the lowest margins.

📌 Conclusion

The business is performing well, with strong revenue growth, excellent sales execution, and predictable seasonal demand. However, growth is increasingly driven by lower-margin product categories and accompanied by a significant concentration of payment risk within the Wholesale channel. Addressing collections performance, improving the revenue mix, and developing high-value wholesale accounts represent the most impactful opportunities to enhance profitability and sustain long-term growth.

However, the business should focus on three areas:

Strengthen collections and credit control to reduce Wholesale payment risk and improve cash flow.
Optimise channel and product mix by encouraging growth in higher-margin products and channels.
Leverage targeted promotions and account support for large Wholesale customers that currently receive little or no trade investment.
Overall Conclusion
