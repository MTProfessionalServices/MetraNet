
                UPDATE t_tax_billsoft_exemptions SET 
                    id_ancestor = :ancestorAccountId,
                    id_acc = :accountId,
                    certificate_id = :certificateId,
                    pcode = :permanentLocationCode,
                    tax_type = :taxType,
                    jur_level = :taxLevel,
                    start_date = :startDate,
                    end_date = :endDate,
                    update_date = SYSDATE
                    WHERE id_tax_exemption = :uniqueId
            