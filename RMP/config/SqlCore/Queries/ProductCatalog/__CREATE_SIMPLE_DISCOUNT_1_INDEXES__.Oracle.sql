
    begin
    /* indexes created in dbinstall/productcatalog */
    execute immediate 'ANALYZE TABLE tmp_discount_1 COMPUTE STATISTICS';
    execute immediate 'ANALYZE INDEX TMP_DISCOUNT_IND_11 COMPUTE STATISTICS';
    execute immediate 'ANALYZE INDEX TMP_DISCOUNT_IND_12 COMPUTE STATISTICS';
    execute immediate 'ANALYZE INDEX TMP_DISCOUNT_IND_13 COMPUTE STATISTICS';
    execute immediate 'ANALYZE INDEX TMP_DISCOUNT_IND_14 COMPUTE STATISTICS';
    end;
