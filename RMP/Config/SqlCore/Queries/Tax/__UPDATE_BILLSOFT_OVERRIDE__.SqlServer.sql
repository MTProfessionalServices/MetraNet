
                UPDATE t_tax_billsoft_override SET 
                    id_ancestor = @ancestorAccountId,
                    id_acc = @accountId,
                    pcode = @permanentLocationCode,
                    tax_type = @taxType,
                    jur_level = @taxLevel,
                    scope = @scope,
                    effectiveDate = @effectiveDate,
                    levelExempt = @exemptLevel,
                    maximum = @maximumBase,
                    replace_jur = @replaceTaxLevel,
                    excess = @excessTaxRate,
                    tax_rate = @taxRate,
                    update_date = GETDATE()
                    WHERE id_tax_override = @uniqueId;
            