CREATE OR REPLACE VIEW v_cohort_analysis AS

WITH
first_orders AS (
    SELECT
        user_external_id,
        DATE_TRUNC('month', MIN(order_date))::DATE AS cohort_month
    FROM orders
    WHERE order_date IS NOT NULL
    GROUP BY user_external_id
),

cohort_sizes AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT user_external_id) AS cohort_size
    FROM first_orders
    GROUP BY cohort_month
),

orders_with_cohort AS (
    SELECT
        o.user_external_id,
        fo.cohort_month,
        (
            DATE_PART('year', DATE_TRUNC('month', o.order_date)::DATE)
            - DATE_PART('year', fo.cohort_month)
        ) * 12
        + (
            DATE_PART('month', DATE_TRUNC('month', o.order_date)::DATE)
            - DATE_PART('month', fo.cohort_month)
        ) AS period_number,
        COALESCE(o.subtotal, 0)
            + COALESCE(o.tax_amount, 0)
            + COALESCE(o.shipping_cost, 0)
            - COALESCE(o.discount_amount, 0) AS order_revenue
    FROM orders o
    JOIN first_orders fo
        ON o.user_external_id = fo.user_external_id
    WHERE
        o.order_date IS NOT NULL
        AND (
            DATE_PART('year', DATE_TRUNC('month', o.order_date)::DATE)
            - DATE_PART('year', fo.cohort_month)
        ) * 12
        + (
            DATE_PART('month', DATE_TRUNC('month', o.order_date)::DATE)
            - DATE_PART('month', fo.cohort_month)
        ) BETWEEN 0 AND 5
),

cohort_activity AS (
    SELECT
        cohort_month,
        period_number,
        COUNT(DISTINCT user_external_id) AS active_customers
    FROM orders_with_cohort
    GROUP BY cohort_month, period_number
),

cohort_revenue AS (
    SELECT
        cohort_month,
        SUM(order_revenue) AS total_cohort_revenue
    FROM orders_with_cohort
    GROUP BY cohort_month
)

SELECT
    cs.cohort_month,
    cs.cohort_size,

    ROUND(
        COALESCE(MAX(CASE WHEN ca.period_number = 0 THEN ca.active_customers END), 0)
        * 100.0 / NULLIF(cs.cohort_size, 0), 2
    ) AS period_0_pct,

    ROUND(
        COALESCE(MAX(CASE WHEN ca.period_number = 1 THEN ca.active_customers END), 0)
        * 100.0 / NULLIF(cs.cohort_size, 0), 2
    ) AS period_1_pct,

    ROUND(
        COALESCE(MAX(CASE WHEN ca.period_number = 2 THEN ca.active_customers END), 0)
        * 100.0 / NULLIF(cs.cohort_size, 0), 2
    ) AS period_2_pct,

    ROUND(
        COALESCE(MAX(CASE WHEN ca.period_number = 3 THEN ca.active_customers END), 0)
        * 100.0 / NULLIF(cs.cohort_size, 0), 2
    ) AS period_3_pct,

    ROUND(
        COALESCE(MAX(CASE WHEN ca.period_number = 4 THEN ca.active_customers END), 0)
        * 100.0 / NULLIF(cs.cohort_size, 0), 2
    ) AS period_4_pct,

    ROUND(
        COALESCE(MAX(CASE WHEN ca.period_number = 5 THEN ca.active_customers END), 0)
        * 100.0 / NULLIF(cs.cohort_size, 0), 2
    ) AS period_5_pct,

    ROUND(COALESCE(cr.total_cohort_revenue, 0), 2)     AS total_cohort_revenue,
    ROUND(
        COALESCE(cr.total_cohort_revenue, 0)
        / NULLIF(cs.cohort_size, 0), 2
    )                                                    AS avg_revenue_per_customer

FROM cohort_sizes cs
LEFT JOIN cohort_activity ca
    ON cs.cohort_month = ca.cohort_month
LEFT JOIN cohort_revenue cr
    ON cs.cohort_month = cr.cohort_month
GROUP BY
    cs.cohort_month,
    cs.cohort_size,
    cr.total_cohort_revenue
ORDER BY
    cs.cohort_month;
