
	    /* Insert a row into the t_tax_billsoft_exemption table */
	    /* and return the id_tax_exemption that was created for this row. */
	    /* */
	    /* idAncestor The parent account of a hierarchy to which this exemption will apply. */
	    /*          -1 if you only want the exemption to apply to a single account. */
	    /*  */
	    /* idAcc The single account which this exemption will apply to.  -1 if you want */
	    /*          the exemption to apply to an account hierarchy */
	    /* */
	    /* uniqueId The uniqueId associated with the added row. OUTPUT parameter */
	    /* */
            create or replace procedure InsertBillSoftExemption(idAcc int, idAncestor int,  uniqueId OUT int)
            as
            begin
                insert into t_tax_billsoft_exemptions 
                    (id_tax_exemption, id_ancestor, id_acc, 
                    pcode, tax_type, jur_level, 
                    start_date, end_date, create_date, 
                    update_date) 
                    values 
                    (seq_t_tax_billsoft_exemptions.nextval, idAncestor, idAcc, 
                    0, 0, 0, 
                    DATE '1970-01-01',DATE '1970-01-01', SYSDATE, 
                    null);

		select seq_t_tax_billsoft_exemptions.CurrVal into uniqueId from dual;
		commit;
                exception
                    when others then
                    select -99 into uniqueId from dual;
            end;
            