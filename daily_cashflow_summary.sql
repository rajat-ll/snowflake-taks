create or replace temporary table outflows as
    select  case when ims.lockin_type='Days' then ipt.start_date + ims.lockin_month 
    ELSE ADD_MONTHS(ipt.start_date, IFF(ims.lockin_month>0, ims.lockin_month, 12)) 
    end as maturity_date, round(sum(balance_principal_amount)/10000000,2) as POS
    from inv_portfolio_transaction ipt
    left join ifa_master_scheme as ims on ipt.scheme_id = ims.id
    left join inv_investor_user as iu on ipt.investor_id = iu.id
    where ifa_id not in (255, 573, 890, 2454) and ipt.transaction_sub_type 
    in ('AddMoney', 'SchemeSwitch', 'Reinvestment') and (ipt.approval_status = 'Approved' 
    and ipt.status = 'Active' and ipt.is_deleted = 'False')
    and maturity_date >= current_date and maturity_date <= ADD_MONTHS(current_date, 60)
     group by all having POS > 0
     order by 1 asc;
    
create or replace temporary table inflows as
    select duedate as DUE_DATE, round(sum(principal_amount + interest_amount)/10000000,2) as POS   
    from m_loan_repayment_schedule mlrs where duedate >= current_date and duedate <= ADD_MONTHS(current_date, 60)
    and loan_id in (select id from m_loan where external_id in (select code from los_application 
    where dealer_id not in (700,433,494,761,929,930,1390))) group by all;
    