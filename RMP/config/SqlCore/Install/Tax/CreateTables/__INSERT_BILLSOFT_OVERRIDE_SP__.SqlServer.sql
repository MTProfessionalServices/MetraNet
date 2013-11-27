
            -- Insert a row into the t_tax_billsoft_override table
            -- and return the id_tax_override that was created for this row.
            --
            -- @idAncestor The parent account of a hierarchy to which this override will apply.
            --          -1 if you only want the override to apply to a single account.
            -- 
            -- @idAcc The single account which this override will apply to.  -1 if you want
            --          the override to apply to an account hierarchy
            --
            -- @uniqueId The uniqueId associated with the added row. OUTPUT parameter
            --
            create proc InsertBillSoftOverride
                @idAncestor int,
                @idAcc int,
                @uniqueId int OUTPUT
                AS
            begin tran
                insert into t_tax_billsoft_override 
                    (id_ancestor, id_acc, pcode, tax_type, jur_level, scope, effectiveDate, levelExempt, maximum, replace_jur, excess, tax_rate, create_date, update_date) values 
                    (@idAncestor, @idAcc, 0,     0,        0,         0,     '1970-01-01',  'f',         0.0,     'f',         0.0,    0.0,      GETDATE(),   null)

                select @uniqueId = @@IDENTITY
            commit tran
            