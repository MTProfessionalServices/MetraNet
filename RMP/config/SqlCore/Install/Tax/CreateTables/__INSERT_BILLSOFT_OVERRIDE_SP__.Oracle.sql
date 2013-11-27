
	    /* Insert a row into the t_tax_billsoft_override table */
	    /* and return the id_tax_override that was created for this row. */
	    /* */
	    /* idAncestor The parent account of a hierarchy to which this override will apply. */
	    /*          -1 if you only want the override to apply to a single account. */
	    /*  */
	    /* idAcc The single account which this override will apply to.  -1 if you want */
	    /*          the override to apply to an account hierarchy */
	    /* */
	    /* uniqueId The uniqueId associated with the added row. OUTPUT parameter */
	    /* */
            create or replace procedure InsertBillSoftOverride(idAncestor int, idAcc int,  uniqueId OUT int)
            as
            begin
                insert into t_tax_billsoft_override 
                    (id_tax_override, id_ancestor, id_acc, 
                    pcode, tax_type, jur_level, 
                    scope, effectiveDate, levelExempt,
                    maximum, replace_jur, excess,
                    tax_rate, create_date, update_date) 
                    values 
                    (seq_t_tax_billsoft_override.nextval, idAcc, idAncestor, 
                    0, 0, 0, 
                    0, DATE '1970-01-01', 'f',
                    0.0, 'f', 0.0,
                    0.0, SYSDATE, null);

		select seq_t_tax_billsoft_override.CurrVal into uniqueId from dual;
		commit;
                exception
                    when others then
                    select -99 into uniqueId from dual;
            end;
            