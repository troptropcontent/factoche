WITH orders AS (
    SELECT *
    FROM organization_projects
    WHERE organization_projects.type = 'Organization::Order'
),
last_version_numbers AS (
    SELECT organization_project_versions.project_id,
        MAX(organization_project_versions.number) as last_version_number
    FROM organization_project_versions
    GROUP BY organization_project_versions.project_id
),
last_versions AS (
    SELECT organization_project_versions.*
    FROM organization_project_versions
        INNER JOIN last_version_numbers ON organization_project_versions.number = last_version_numbers.last_version_number
        AND organization_project_versions.project_id = last_version_numbers.project_id
),
invoices AS (
    SELECT *
    FROM accounting_financial_transactions
    WHERE accounting_financial_transactions.type = 'Accounting::Invoice'
),
credit_notes AS (
    SELECT *
    FROM accounting_financial_transactions
    WHERE accounting_financial_transactions.type = 'Accounting::CreditNote'
),
amount_invoiced_per_orders AS (
    SELECT organization_project_versions.project_id,
        COALESCE(SUM(invoices.total_excl_tax_amount), 0.00) - COALESCE(SUM(credit_notes.total_excl_tax_amount), 0.00) as total_excl_tax_amount
    FROM organization_project_versions
        LEFT JOIN invoices ON organization_project_versions.id = invoices.holder_id
        LEFT JOIN credit_notes ON invoices.id = credit_notes.holder_id
    GROUP BY organization_project_versions.project_id
)
SELECT orders.id as order_id,
    last_versions.total_excl_tax_amount as order_total_amount,
    amount_invoiced_per_orders.total_excl_tax_amount as invoiced_total_amount,
    ROUND(
        amount_invoiced_per_orders.total_excl_tax_amount / last_versions.total_excl_tax_amount,
        2
    ) as completion_percentage
FROM orders
    LEFT JOIN last_versions ON orders.id = last_versions.project_id
    LEFT JOIN amount_invoiced_per_orders ON orders.id = amount_invoiced_per_orders.project_id;