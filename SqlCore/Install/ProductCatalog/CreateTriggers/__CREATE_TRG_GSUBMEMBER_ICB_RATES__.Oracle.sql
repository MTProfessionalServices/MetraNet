
CREATE OR REPLACE TRIGGER trg_gsubmember_icb_rates
AFTER INSERT OR UPDATE ON t_gsubmember
FOR EACH ROW
BEGIN
    mt_rate_pkg.recursive_inherit_sub(
        v_id_audit => NULL,
        v_id_acc   => :NEW.id_acc,
        v_id_sub   => NULL,
        v_id_group => :NEW.id_group
    );
END;
