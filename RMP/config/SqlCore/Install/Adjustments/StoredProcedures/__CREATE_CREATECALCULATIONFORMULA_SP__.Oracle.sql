
        CREATE OR REPLACE PROCEDURE CREATECALCULATIONFORMULA(
            p_tx_formula CLOB,
            p_id_engine INT,
            op_id_prop OUT int )
        as
        begin
            /* ESR-4483 change datatype of parameter p_tx_formula to CLOB */
            INSERT INTO t_calc_formula
            (ID_FORMULA, tx_formula,id_engine) VALUES (seq_t_calc_formula.nextval,  p_tx_formula, p_id_engine);
            SELECT seq_t_calc_formula.currval INTO op_id_prop FROM DUAL;
        exception
        when others then
            op_id_prop := -99;
        END;
			