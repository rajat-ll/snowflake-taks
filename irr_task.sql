    CREATE OR REPLACE TEMPORARY TABLE NDV_MIFOS_IRR_POS_DATA_OPENING_TEST AS
    SELECT ml.id, ml.expected_xirr,
        SUM(IFF(
                ZEROIFNULL(mlirs.principal_amount) >
                (ZEROIFNULL(mlirs.principal_completed_derived) +
                ZEROIFNULL(mlirs.principal_writtenoff_derived)), 1, 0)
        ) AS pending_emi_count,
        ROUND(SUM(
                ZEROIFNULL(mlirs.principal_amount) -
                (ZEROIFNULL(mlirs.principal_completed_derived) +
                ZEROIFNULL(mlirs.principal_writtenoff_derived))), 2
        ) AS irr_pos
    FROM m_loan ml
    LEFT OUTER JOIN m_loan_irr_repayment_schedule mlirs
    ON ml.id = mlirs.loan_id
    WHERE ml.loan_status_id IN (300, 600, 700)
    GROUP BY ALL;
