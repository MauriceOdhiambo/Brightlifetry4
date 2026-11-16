-- BRIGHTLIFE CBO — APP-FIRST PORTAL, LOAN PRODUCTS & HISTORY IMPORT
-- ADDITIVE MIGRATION ONLY. Run against the existing production Supabase database.
-- Do NOT run the large fresh-install script in the supplied SQL file: it contains DROP TABLE statements.

ALTER TABLE public.members ADD COLUMN IF NOT EXISTS shares_owned NUMERIC(14,2) NOT NULL DEFAULT 0;
ALTER TABLE public.members ADD COLUMN IF NOT EXISTS source_total_savings NUMERIC(14,2);
ALTER TABLE public.members ADD COLUMN IF NOT EXISTS joining_date TIMESTAMP;
ALTER TABLE public.members ADD COLUMN IF NOT EXISTS date_of_birth DATE;
ALTER TABLE public.members ADD COLUMN IF NOT EXISTS gender TEXT;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS loan_type TEXT;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS reference_no TEXT;
ALTER TABLE public.loan_repayments ADD COLUMN IF NOT EXISTS reference_no TEXT;
ALTER TABLE public.transactions ADD COLUMN IF NOT EXISTS reference_no TEXT;
ALTER TABLE public.transactions ADD COLUMN IF NOT EXISTS confirmed_by TEXT;
ALTER TABLE public.transactions ADD COLUMN IF NOT EXISTS approved_by TEXT;
ALTER TABLE public.transactions ADD COLUMN IF NOT EXISTS remarks TEXT;
ALTER TABLE public.transactions ADD COLUMN IF NOT EXISTS source_running_balance NUMERIC(14,2);

CREATE UNIQUE INDEX IF NOT EXISTS ux_loans_reference_no_nonempty
  ON public.loans (upper(btrim(reference_no))) WHERE reference_no IS NOT NULL AND btrim(reference_no) <> '';
CREATE UNIQUE INDEX IF NOT EXISTS ux_loan_repayments_reference_no_nonempty
  ON public.loan_repayments (upper(btrim(reference_no))) WHERE reference_no IS NOT NULL AND btrim(reference_no) <> '';
CREATE UNIQUE INDEX IF NOT EXISTS ux_transactions_reference_no_nonempty
  ON public.transactions (upper(btrim(reference_no))) WHERE reference_no IS NOT NULL AND btrim(reference_no) <> '';

-- Store all five products/rates as fractions: 0.20 = 20% of principal (flat per loan).
INSERT INTO public.settings (loan_interest_rates)
SELECT '{"emergency":0.20,"7":0.12,"14":0.16,"20":0.18,"30":0.20}'::jsonb
WHERE NOT EXISTS (SELECT 1 FROM public.settings);

UPDATE public.settings
SET loan_interest_rates = '{"emergency":0.20,"7":0.12,"14":0.16,"20":0.18,"30":0.20}'::jsonb,
    updated_at = NOW()
WHERE id IN (SELECT id FROM public.settings ORDER BY created_at DESC NULLS LAST LIMIT 1);

COMMENT ON COLUMN public.loans.loan_type IS 'Brightlife loan product: Emergency Loan, 1-7 Days Loan, 8-14 Days Loan, 15-20 Days Loan, or 21-30 Days Loan.';
COMMENT ON COLUMN public.loans.reference_no IS 'Source-system loan reference such as L0001, retained during history migration.';
COMMENT ON COLUMN public.loan_repayments.reference_no IS 'Source-system repayment reference such as RP0001.';
COMMENT ON COLUMN public.transactions.reference_no IS 'Source-system savings or transaction reference such as SAV0001.';

-- Additional source-compatible fields from the workbook.
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS requested_amount NUMERIC(14,2);
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS interest_amount NUMERIC(14,2);
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS approved_amount NUMERIC(14,2);
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS disbursed_amount NUMERIC(14,2);
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS disbursement_date TIMESTAMPTZ;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS frequency TEXT;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS term_days INTEGER;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS installment_amount NUMERIC(14,2);
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS guarantors_count INTEGER;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS guaranteed_amount NUMERIC(14,2);
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS loan_to_value NUMERIC(14,4);
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS approved_by_name TEXT;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS disbursed_by_name TEXT;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS remarks TEXT;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS due_day INTEGER;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS principal_due_per_month NUMERIC(14,2);
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS maturity_date DATE;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS grace_period_end DATE;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS penalty_start_date DATE;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS last_payment_date TIMESTAMPTZ;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS payments_made INTEGER NOT NULL DEFAULT 0;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS days_overdue INTEGER NOT NULL DEFAULT 0;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS arrears NUMERIC(14,2) NOT NULL DEFAULT 0;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS payment_status TEXT;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS source_status TEXT;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS source_principal_outstanding NUMERIC(14,2);
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS source_interest_outstanding NUMERIC(14,2);
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS source_total_outstanding NUMERIC(14,2);
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS source_arrears NUMERIC(14,2);
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS source_days_overdue INTEGER;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS next_due_date DATE;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS principal_paid NUMERIC(14,2) NOT NULL DEFAULT 0;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS interest_paid NUMERIC(14,2) NOT NULL DEFAULT 0;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS penalties_paid NUMERIC(14,2) NOT NULL DEFAULT 0;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS principal_outstanding NUMERIC(14,2);
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS interest_outstanding NUMERIC(14,2);
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS penalty_outstanding NUMERIC(14,2) NOT NULL DEFAULT 0;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS total_outstanding NUMERIC(14,2);

ALTER TABLE public.loan_repayments ADD COLUMN IF NOT EXISTS installment_number INTEGER;
ALTER TABLE public.loan_repayments ADD COLUMN IF NOT EXISTS due_date DATE;
ALTER TABLE public.loan_repayments ADD COLUMN IF NOT EXISTS days_late INTEGER NOT NULL DEFAULT 0;
ALTER TABLE public.loan_repayments ADD COLUMN IF NOT EXISTS days_overdue INTEGER NOT NULL DEFAULT 0;
ALTER TABLE public.loan_repayments ADD COLUMN IF NOT EXISTS penalty_status TEXT;
ALTER TABLE public.loan_repayments ADD COLUMN IF NOT EXISTS principal_due NUMERIC(14,2) NOT NULL DEFAULT 0;
ALTER TABLE public.loan_repayments ADD COLUMN IF NOT EXISTS penalty_paid NUMERIC(14,2) NOT NULL DEFAULT 0;
ALTER TABLE public.loan_repayments ADD COLUMN IF NOT EXISTS interest_paid NUMERIC(14,2) NOT NULL DEFAULT 0;
ALTER TABLE public.loan_repayments ADD COLUMN IF NOT EXISTS principal_paid NUMERIC(14,2) NOT NULL DEFAULT 0;
ALTER TABLE public.loan_repayments ADD COLUMN IF NOT EXISTS confirmed_by TEXT;
ALTER TABLE public.loan_repayments ADD COLUMN IF NOT EXISTS approved_by TEXT;
ALTER TABLE public.loan_repayments ADD COLUMN IF NOT EXISTS remarks TEXT;
ALTER TABLE public.loan_repayments ADD COLUMN IF NOT EXISTS source_interest_outstanding NUMERIC(14,2);
ALTER TABLE public.loan_repayments ADD COLUMN IF NOT EXISTS source_principal_outstanding NUMERIC(14,2);
ALTER TABLE public.loan_repayments ADD COLUMN IF NOT EXISTS source_running_balance NUMERIC(14,2);
ALTER TABLE public.loan_repayments ADD COLUMN IF NOT EXISTS allocation_recorded BOOLEAN NOT NULL DEFAULT FALSE;

-- Rebuildable ledger views: allocate each repayment to interest first, then principal.
-- Penalties are kept separate and are not auto-assessed because no penalty rate/cap was supplied.
CREATE OR REPLACE VIEW public.brightlife_repayment_ledger WITH (security_invoker = true) AS
WITH ordered AS (
  SELECT r.*, l.amount AS loan_principal,
         GREATEST(COALESCE(l.total_repayment, l.amount * (1 + COALESCE(l.interest_rate,0))) - l.amount, 0) AS loan_interest,
         COALESCE(l.repayment_due_date::date, l.maturity_date) AS loan_due_date,
         ROW_NUMBER() OVER (PARTITION BY r.loan_id ORDER BY r.payment_date, r.created_at, r.id) AS calc_installment,
         COALESCE(SUM(r.amount) OVER (PARTITION BY r.loan_id ORDER BY r.payment_date, r.created_at, r.id ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),0) AS prior_paid,
         SUM(r.amount) OVER (PARTITION BY r.loan_id ORDER BY r.payment_date, r.created_at, r.id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_paid
  FROM public.loan_repayments r JOIN public.loans l ON l.id=r.loan_id
), allocated AS (
  SELECT o.*,
         CASE WHEN o.allocation_recorded THEN COALESCE(o.interest_paid,0)
              ELSE LEAST(o.amount,GREATEST(o.loan_interest-o.prior_paid,0)) END AS applied_interest_paid,
         CASE WHEN o.allocation_recorded THEN COALESCE(o.principal_paid,0)
              ELSE GREATEST(o.amount-LEAST(o.amount,GREATEST(o.loan_interest-o.prior_paid,0)),0) END AS applied_principal_paid
  FROM ordered o
), cumulative AS (
  SELECT a.*,
         SUM(applied_interest_paid) OVER (PARTITION BY loan_id ORDER BY payment_date,created_at,id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_interest_paid,
         SUM(applied_principal_paid) OVER (PARTITION BY loan_id ORDER BY payment_date,created_at,id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_principal_paid
  FROM allocated a
)
SELECT id, loan_id, member_id, amount, payment_method, mpesa_code, reference_no,
       payment_date, COALESCE(installment_number,calc_installment) AS installment_number,
       COALESCE(due_date,loan_due_date) AS due_date,
       CASE WHEN days_late>0 THEN days_late ELSE GREATEST(payment_date::date-COALESCE(due_date,loan_due_date),0) END AS days_late,
       CASE WHEN days_overdue>0 THEN days_overdue ELSE GREATEST(payment_date::date-COALESCE(due_date,loan_due_date),0) END AS days_overdue,
       COALESCE(penalty_status,CASE WHEN payment_date::date<=COALESCE(due_date,loan_due_date) THEN 'On Time' ELSE 'Late' END) AS penalty_status,
       principal_due, COALESCE(penalty_paid,0) AS penalty_paid,
       applied_interest_paid AS interest_paid,
       applied_principal_paid AS principal_paid,
       amount AS total_paid,
       GREATEST(loan_interest-cumulative_interest_paid,0) AS interest_outstanding,
       GREATEST(loan_principal-cumulative_principal_paid,0) AS principal_outstanding,
       running_paid AS running_balance, confirmed_by, approved_by, remarks
FROM cumulative;

CREATE OR REPLACE VIEW public.brightlife_loan_balances WITH (security_invoker = true) AS
WITH paid AS (
  SELECT loan_id, COALESCE(SUM(total_paid),0) AS total_paid,
         COALESCE(SUM(principal_paid),0) AS principal_paid,
         COALESCE(SUM(interest_paid),0) AS interest_paid,
         COUNT(*) AS payments_made, MAX(payment_date) AS last_payment_date
  FROM public.brightlife_repayment_ledger GROUP BY loan_id
), balances AS (
  SELECT l.*,
         CASE WHEN p.loan_id IS NOT NULL THEN p.total_paid
              WHEN l.source_status IS NOT NULL THEN COALESCE(l.principal_paid,0)+COALESCE(l.interest_paid,0)+COALESCE(l.penalties_paid,0)
              ELSE COALESCE(l.amount_paid,0) END AS paid_total,
         CASE WHEN p.loan_id IS NOT NULL THEN p.principal_paid
              WHEN l.source_status IS NOT NULL THEN COALESCE(l.principal_paid,0)
              ELSE LEAST(l.amount,GREATEST(COALESCE(l.amount_paid,0)-GREATEST(COALESCE(l.total_repayment,l.amount*(1+COALESCE(l.interest_rate,0)))-l.amount,0),0)) END AS paid_principal,
         CASE WHEN p.loan_id IS NOT NULL THEN p.interest_paid
              WHEN l.source_status IS NOT NULL THEN COALESCE(l.interest_paid,0)
              ELSE LEAST(GREATEST(COALESCE(l.total_repayment,l.amount*(1+COALESCE(l.interest_rate,0)))-l.amount,0),COALESCE(l.amount_paid,0)) END AS paid_interest,
         COALESCE(p.payments_made,l.payments_made,0) AS payment_count,
         COALESCE(p.last_payment_date,l.last_payment_date) AS last_paid_at,
         (p.loan_id IS NOT NULL) AS has_ledger,
         GREATEST(COALESCE(l.total_repayment,l.amount*(1+COALESCE(l.interest_rate,0)))-l.amount,0) AS total_interest
  FROM public.loans l LEFT JOIN paid p ON p.loan_id=l.id
)
SELECT id, reference_no, member_id, loan_type, amount AS principal, total_interest AS interest_amount,
       paid_total AS total_paid, paid_principal AS principal_paid, paid_interest AS interest_paid,
       CASE WHEN NOT has_ledger AND source_principal_outstanding IS NOT NULL THEN GREATEST(source_principal_outstanding,0) ELSE GREATEST(amount-paid_principal,0) END AS principal_outstanding,
       CASE WHEN NOT has_ledger AND source_interest_outstanding IS NOT NULL THEN GREATEST(source_interest_outstanding,0) ELSE GREATEST(total_interest-paid_interest,0) END AS interest_outstanding,
       COALESCE(penalty_outstanding,0) AS penalty_outstanding,
       CASE WHEN NOT has_ledger AND source_total_outstanding IS NOT NULL THEN GREATEST(source_total_outstanding,0) ELSE GREATEST(amount+total_interest-paid_total+COALESCE(penalty_outstanding,0),0) END AS total_outstanding,
       last_paid_at AS last_payment_date, payment_count AS payments_made,
       CASE WHEN NOT has_ledger AND source_days_overdue IS NOT NULL THEN source_days_overdue
            WHEN GREATEST(amount+total_interest-paid_total+COALESCE(penalty_outstanding,0),0)<=0.01 THEN 0
            ELSE GREATEST(CURRENT_DATE-COALESCE(maturity_date,repayment_due_date::date),0) END AS days_overdue,
       CASE WHEN has_ledger AND GREATEST(amount+total_interest-paid_total+COALESCE(penalty_outstanding,0),0)<=0.01 THEN 'Paid'
            WHEN NOT has_ledger AND payment_status IS NOT NULL THEN payment_status
            WHEN COALESCE(maturity_date,repayment_due_date::date)<CURRENT_DATE THEN 'Overdue' ELSE 'Current' END AS payment_status,
       repayment_due_date, maturity_date, term_days, frequency, installment_amount, COALESCE(source_arrears,arrears) AS arrears
FROM balances;

CREATE OR REPLACE VIEW public.brightlife_savings_ledger WITH (security_invoker = true) AS
SELECT t.id, t.member_id, t.created_at AS transaction_date, t.type, t.amount,
       t.payment_method, t.mpesa_code, t.reference_no,
       SUM(CASE WHEN t.type='savings' THEN t.amount WHEN t.type='withdrawal' THEN -t.amount ELSE 0 END)
         OVER (PARTITION BY t.member_id ORDER BY t.created_at,t.id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_balance,
       t.description, t.status
FROM public.transactions t
WHERE t.type IN ('savings','withdrawal') AND t.status='completed';
