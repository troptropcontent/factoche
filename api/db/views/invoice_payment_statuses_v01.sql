WITH invoices AS (
    SELECT *
    FROM accounting_financial_transactions
    WHERE accounting_financial_transactions.type = 'Accounting::Invoice'
),
invoice_payments AS (
    SELECT invoices.id as invoice_id,
        SUM(COALESCE(accounting_payments.amount, 0)) as invoice_payment
    FROM invoices
        LEFT JOIN accounting_payments ON accounting_payments.invoice_id = invoices.id
    GROUP BY invoices.id
),
invoice_balances AS (
    SELECT invoices.id as invoice_id,
        invoices.total_excl_retention_guarantee_amount - invoice_payments.invoice_payment as balance
    FROM invoices
        LEFT JOIN invoice_payments ON invoice_payments.invoice_id = invoices.id
)
SELECT invoice_balances.invoice_id,
    CASE
        WHEN invoice_balances.balance = 0 THEN 'paid'
        WHEN accounting_financial_transaction_details.due_date < COALESCE(
            NULLIF(current_setting('app.now', true), '')::timestamp,
            -- only for testing purposes in order to mock now()
            now()
        ) THEN 'overdue'
        ELSE 'pending'
    END AS status
FROM invoice_balances
    LEFT JOIN accounting_financial_transaction_details ON accounting_financial_transaction_details.financial_transaction_id = invoice_balances.invoice_id