
    begin
    /* indexes created in dbinstall/productcatalog */
    execute immediate 'TRUNCATE TABLE tmp_discount_1';
    execute immediate 'ANALYZE TABLE tmp_discount_2 COMPUTE STATISTICS';
    execute immediate 'ANALYZE INDEX TMP_DISCOUNT_IND_21 COMPUTE STATISTICS';
    execute immediate 'ANALYZE INDEX TMP_DISCOUNT_IND_22 COMPUTE STATISTICS';
    end;
