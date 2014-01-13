
            -- Insert a row into the t_tax_billsoft_exemption table
            -- and return the id_tax_exemption that was created for this row.
            --
            -- @idAncestor The parent account of a hierarchy to which this exemption will apply.
            --          -1 if you only want the exemption to apply to a single account.
            -- 
            -- @idAcc The single account which this exemption will apply to.  -1 if you want
            --          the exemption to apply to an account hierarchy
            --
            -- @uniqueId The uniqueId associated with the added row. OUTPUT parameter
            --
            create proc InsertBillSoftExemption
                @idAncestor int,
                @idAcc int,
                @uniqueId int OUTPUT
                AS
            begin tran
                insert into t_tax_billsoft_exemptions 
                    (id_ancestor, id_acc, pcode, tax_type, jur_level, start_date,   end_date,     create_date, update_date) values 
                    (@idAncestor, @idAcc, 0,     0,        0,         '1970-01-01', '1970-01-01', GETDATE(),   null)

                select @uniqueId = @@IDENTITY
            commit tran
            