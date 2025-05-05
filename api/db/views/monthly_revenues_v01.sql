SELECT invoices.company_id,
    date_part('year', invoices.issue_date)::integer AS year,
    date_part('month', invoices.issue_date)::integer AS month,
    SUM(
        invoices.total_excl_tax_amount - COALESCE(credit_notes.total_excl_tax_amount, 0)
    ) AS total_revenue
FROM accounting_financial_transactions AS invoices
    LEFT JOIN accounting_financial_transactions AS credit_notes ON credit_notes.holder_id = invoices.id
    AND credit_notes.type = 'Accounting::CreditNote'
WHERE invoices.type = 'Accounting::Invoice'
GROUP BY invoices.company_id,
    year,
    month