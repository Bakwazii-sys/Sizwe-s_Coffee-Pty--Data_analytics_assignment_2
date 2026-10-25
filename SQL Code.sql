#Sizwe's Coffee Analysis Project

__________________________________________________________________________________________________________________________________________________________________
Task 1:Channel performance 
__________________________________________________________________________________________________________________________________________________________________

WITH channel_revenue AS (
    SELECT
        so.channel,
        CASE
            WHEN so.order_date <= '2024-06-30' THEN 'FY2024'
            ELSE 'FY2025'
        END AS financial_year,
        SUM(sl.line_revenue) AS revenue
    FROM workspace.default.sales_orders so
    JOIN workspace.default.sales_lines sl
        ON so.order_id = sl.order_id
    GROUP BY so.channel,
             CASE
                WHEN so.order_date <= '2024-06-30' THEN 'FY2024'
                ELSE 'FY2025'
             END
)
SELECT
    channel,
    SUM(CASE WHEN financial_year = 'FY2024' THEN revenue END) AS fy2024_revenue,
    SUM(CASE WHEN financial_year = 'FY2025' THEN revenue END) AS fy2025_revenue,
    ROUND(
        (
            SUM(CASE WHEN financial_year = 'FY2025' THEN revenue END)
            -
            SUM(CASE WHEN financial_year = 'FY2024' THEN revenue END)
        ) * 100.0
        /
        NULLIF(
            SUM(CASE WHEN financial_year = 'FY2024' THEN revenue END),
            0
        ),
        2
    ) AS growth_rate_pct
FROM channel_revenue
GROUP BY channel;

Findings: Answer
channel	fy2024_revenue	fy2025_revenue	growth_rate_pct
Wholesale	308166012.3200077	335426325.0200068	8.85
Subscription	132833985.1499977	144573698.33000264	8.84

Answer: Both channels grew ~8.8% year over year; Wholesale remains the dominant channel at roughly 2.3× Subscription's revenue. 
The data spans exactly 2023-07-01 → 2025-06-27, so the fiscal-year split cleanly covers both periods.

______________________________________________________________________________________________________________________________________________________________
Task 2: Where the profit actually comes from
______________________________________________________________________________________________________________________________________________________________

WITH line_detail AS (
    SELECT
        p.product_line,
        sl.line_revenue,
        sl.cogs
    FROM workspace.default.sales_lines sl
    JOIN workspace.default.products p
        ON sl.sku = p.sku
)
SELECT
    product_line,
    SUM(line_revenue) AS revenue,
    SUM(cogs) AS cost_of_goods,
    SUM(line_revenue - cogs) AS gross_profit,
    ROUND(
        (
            SUM(line_revenue - cogs) * 100.0
            /
            NULLIF(SUM(line_revenue), 0)
        ),
        2
    ) AS gross_margin_pct
FROM line_detail
GROUP BY product_line
ORDER BY gross_profit DESC;

House Blend earns the most profit, but Single Origin earns the highest margin. So, not the same line earns the highest margin

_______________________________________________________________________________________________________________________________________________________________
Task 3:The collections problem
_______________________________________________________________________________________________________________________________________________________________

WITH invoices AS (
    SELECT
        c.channel,
        ar.invoice_date,
        ar.invoice_amount,
        ar.amount_settled,
        ar.settlement_date,
        CASE WHEN ar.amount_settled >= ar.invoice_amount THEN 1 ELSE 0 END AS is_settled
    FROM workspace.default.ar_ledger ar
    JOIN workspace.default.customers c
        ON ar.customer_id = c.customer_id
)
SELECT
    channel,
    COUNT(*) AS n_invoices,
    SUM(is_settled) AS n_settled,
    COUNT(*) - SUM(is_settled) AS n_open,
    ROUND(
        AVG(CASE WHEN is_settled = 1 THEN datediff(settlement_date, invoice_date) END),
        1
    ) AS avg_days_to_settle,
    ROUND(
        SUM(CASE WHEN is_settled = 0 THEN invoice_amount - amount_settled END),
        2
    ) AS value_outstanding
FROM invoices
GROUP BY channel
ORDER BY value_outstanding DESC;

Findings:The problem sits in the Wholesale channel as it holds all but 44 of the open invoices, takes 68.7 days on average to settle versus 3.8 for the 
Subscription channel, and accounts for essentially all of the ~R88.6M outstanding. Nomsa's suspicion is real, the Wholesale's average settlement time 
worsened from 56.9 days in FY2024 to 84.1 in FY2025 (paid invoices per year), while Subscription stayed flat at 3.8. I'd investigate Wholesale first, 
and specifically its large open balance of 3,454 unpaid invoices worth ~R87.8M.

_________________________________________________________________________________________________________________________________________________________
Task 4:The ten accounts that matter most 
_________________________________________________________________________________________________________________________________________________________

WITH fy2025_customer_lines AS (
    SELECT
        c.trading_name,
        c.segment,
        c.province,
        r.rep_name,
        sl.line_revenue
    FROM customers c
    JOIN sales_orders so
        ON c.customer_id = so.customer_id
    JOIN sales_lines sl
        ON so.order_id = sl.order_id
    LEFT JOIN reps r
        ON c.rep_id = r.rep_id
    WHERE so.order_date > '2024-06-30'
)
SELECT
    trading_name AS customer_name,
    segment,
    province,
    rep_name,
    SUM(line_revenue) AS fy2025_revenue
FROM fy2025_customer_lines
GROUP BY
    trading_name,
    segment,
    province,
    rep_name
ORDER BY fy2025_revenue DESC
LIMIT 10;

Findings: Bongani's one-pager is ready. It shows Halvane Retail Group as the largest customer dominating with the most highest revenue. 

____________________________________________________________________________________________________________________________________________________________
Task 5:A commercial gap
____________________________________________________________________________________________________________________________________________________________

WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.trading_name AS customer_name,
        c.segment,
        c.province,
        SUM(sl.line_revenue) AS revenue
    FROM customers c
    JOIN sales_orders so
        ON c.customer_id = so.customer_id
    JOIN sales_lines sl
        ON so.order_id = sl.order_id
    WHERE c.channel = 'Wholesale'
    GROUP BY
        c.customer_id,
        c.trading_name,
        c.segment,
        c.province
)
SELECT
    cr.customer_name,
    cr.segment,
    cr.province,
    cr.revenue
FROM customer_revenue cr
LEFT JOIN trade_promotions tp
    ON cr.customer_id = tp.customer_id
WHERE tp.customer_id IS NULL
ORDER BY cr.revenue DESC
LIMIT 15;

Findings:Umhlanga Fresh, Ridgeway Foods and Kalahari Kitchen Given these three accounts spend R6.2- R4.4M with Sizwe yet have never received a cent of 
promotional support. I would have their reps propose a targeted volume rebate / listing support package in the coming quarter.

________________________________________________________________________________________________________________________________________________________________
Task 6:Are the sales representatives hitting target?
________________________________________________________________________________________________________________________________________________________________

WITH fy2025_revenue AS (
    SELECT
        so.rep_id,
        SUM(sl.line_revenue) / 12.0 AS monthly_average
    FROM sales_orders so
    JOIN sales_lines sl
        ON so.order_id = sl.order_id
    WHERE so.order_date > '2024-06-30'
    GROUP BY so.rep_id
)
SELECT
    r.rep_name,
    r.territory,
    r.target_monthly AS monthly_target,
    COALESCE(fr.monthly_average, 0) AS actual_monthly_average,
    ROUND(
        COALESCE(fr.monthly_average, 0) * 100.0
        / NULLIF(r.target_monthly, 0),
        2
    ) AS pct_of_target
FROM reps r
LEFT JOIN fy2025_revenue fr
    ON r.rep_id = fr.rep_id
ORDER BY pct_of_target DESC;

Findings:16 of 18 reps are above 100% of their monthly target with the top four (Karabo van Wyk, Kagiso Mkhize, Johan Maluleke, Anele Naidoo) 
blowing past 220%, peaking at 250%

_____________________________________________________________________________________________________________________________________________________________
Task 7: The shape of the year 
_____________________________________________________________________________________________________________________________________________________________
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(so.order_date, 'yyyy-MM-01') AS month_start,
        SUM(sl.line_revenue) AS revenue
    FROM sales_orders so
    JOIN sales_lines sl
        ON so.order_id = sl.order_id
    GROUP BY DATE_FORMAT(so.order_date, 'yyyy-MM-01')
)
SELECT
    month_start,
    revenue,
    ROUND(
        (
            revenue
            - LAG(revenue) OVER (ORDER BY month_start)
        ) * 100.0
        /
        NULLIF(
            LAG(revenue) OVER (ORDER BY month_start),
            0
        ),
        2
    ) AS pct_change_previous_month,
    ROUND(
        AVG(revenue) OVER (
            ORDER BY month_start
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS rolling_3_month_average
FROM monthly_revenue
ORDER BY month_start;


Finding:Yes, Every year follows the same curve: sales fall from July to December, then rise from January to June.
December is the quietest month about R30M, versus about R45M in June. That's roughly a third less.
It happens every year, Dec 2023 fell 13%, Dec 2024 fell 12.9% which is almost identical.
Overall the business is growing: each June peak is ~9% higher than the last.

__________________________________________________________________________________________________________________________________________________________
Task 8:Why has the margin moved?
___________________________________________________________________________________________________________________________________________________________

WITH product_year_metrics AS (
    SELECT
        p.product_line,
        CASE
            WHEN so.order_date <= '2024-06-30' THEN 'FY2024'
            ELSE 'FY2025'
        END AS financial_year,
        SUM(sl.line_revenue) AS revenue,
        SUM(sl.line_revenue - sl.cogs) AS gross_profit
    FROM sales_orders so
    JOIN sales_lines sl
        ON so.order_id = sl.order_id
    JOIN products p
        ON sl.sku = p.sku
    GROUP BY
        p.product_line,
        CASE
            WHEN so.order_date <= '2024-06-30' THEN 'FY2024'
            ELSE 'FY2025'
        END
)
SELECT
    product_line,
    financial_year,
    revenue,
    ROUND(gross_profit * 100.0 / NULLIF(revenue, 0), 2) AS gross_margin_pct,
    ROUND(
        revenue * 100.0
        /
        SUM(revenue) OVER (
            PARTITION BY financial_year
        ),
        2
    ) AS revenue_share_pct
FROM product_year_metrics
ORDER BY product_line, financial_year;


Findings:No product line got less profitable — every line's margin was flat or slightly up (Bulk Commercial 19.89% to 19.91%, House Blend 38.32% to 38.34%, 
Single Origin 44.24% to 44.31%). '
The decline is entirely a mix shift: Bulk Commercial, the lowest-margin line at ~19.9%, grew revenue by R51.2M (+46%, 110.3M to 161.5M) and 
jumped from 25.02% to 33.65% of total revenue, while all four higher-margin lines (35.8%–44.3%) shrank in share. House Blend 32.14% to 28.71%, 
Single Origin 19.45% to 17.57%, Capsules 12.88% to 10.84%, Decaf 10.50% to 9.24%. Weighting each year's shares by its margins reproduces 
the headline exactly: 34.7% blended in FY2024 falling to 33.0% in FY2025. 
In short, Sizwe bought its 9% revenue growth by selling a lot more low-margin bulk coffee and slightly less of everything else. 
