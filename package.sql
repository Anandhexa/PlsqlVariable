-- Creating a package for transaction handling
CREATE OR REPLACE PACKAGE debit_card_pkg AS
    -- Procedure for processing transactions
    PROCEDURE process_transaction(
        p_customer_id        IN NUMBER,
        p_transaction_type   IN VARCHAR2,
        p_transaction_amount IN NUMBER
    );

    -- Function to calculate transaction fee
    FUNCTION calculate_fee(
        p_transaction_type   IN VARCHAR2,
        p_transaction_amount IN NUMBER
    ) RETURN NUMBER;

END debit_card_pkg;
/

-- Implementing the package body
CREATE OR REPLACE PACKAGE BODY debit_card_pkg AS

    -- Constants
    c_atm_transaction       CONSTANT VARCHAR2(20) := 'ATM';


    -- Function to calculate transaction fee
    FUNCTION calculate_fee(
        p_transaction_type   IN VARCHAR2,
        p_transaction_amount IN NUMBER
    ) RETURN NUMBER IS
        v_fee NUMBER;
    BEGIN
        CASE p_transaction_type
            WHEN c_atm_transaction THEN
                v_fee := c_atm_fee;
            WHEN c_pos_transaction THEN
                v_fee := p_transaction_amount * c_pos_fee_percentage;
            WHEN c_p2p_transaction THEN
                v_fee := p_transaction_amount * c_p2p_fee_percentage;
            WHEN c_deposit_transaction THEN
                v_fee := c_deposit_fee;
            ELSE
                RAISE_APPLICATION_ERROR(-20001, 'Invalid transaction type.');
        END CASE;

        RETURN ROUND(v_fee, 2);
    END calculate_fee;

    -- Function to validate daily transaction limits
    FUNCTION validate_daily_limit(
        p_transaction_type   IN VARCHAR2,
        p_transaction_amount IN NUMBER
    ) RETURN BOOLEAN IS
        v_daily_limit NUMBER;
    BEGIN
        CASE p_transaction_type
            WHEN c_atm_transaction THEN
                v_daily_limit := c_atm_daily_limit;
            WHEN c_pos_transaction THEN
                v_daily_limit := c_pos_daily_limit;
            WHEN c_p2p_transaction THEN
                v_daily_limit := c_p2p_daily_limit;
            ELSE
                RETURN TRUE; -- Deposits have no limit
        END CASE;

        IF p_transaction_amount > v_daily_limit THEN
            RETURN FALSE;
        ELSE
            RETURN TRUE;
        END IF;
    END validate_daily_limit;

END debit_card_pkg;
/

