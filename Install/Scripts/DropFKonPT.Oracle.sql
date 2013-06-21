BEGIN
    FOR rec IN (
        SELECT 'ALTER TABLE ' || uc.table_name || ' DROP CONSTRAINT ' || uc.constraint_name AS sqlText
        FROM   user_constraints uc
        WHERE  uc.constraint_type = 'R' AND uc.r_constraint_name = 'T_RSCHED_PK' AND uc.table_name LIKE 'T\_PT\_%' ESCAPE '\'
    )
    LOOP
        EXECUTE IMMEDIATE (rec.sqlText);
    END LOOP;
END;

