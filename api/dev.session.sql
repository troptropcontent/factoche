SELECT invoices.*
FROM accounting_financial_transactions as invoices
    LEFT JOIN accounting_financial_transactions as credit_notes ON credit_notes.holder_id = invoices.id
    AND credit_notes.type = 'Accounting::CreditNote'
WHERE invoices.type = 'Accounting::Invoice'