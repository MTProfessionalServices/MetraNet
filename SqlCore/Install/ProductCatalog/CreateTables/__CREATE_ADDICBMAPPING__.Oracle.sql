
CREATE OR REPLACE PROCEDURE ADDICBMAPPING (
   temp_id_paramtable    t_pl_map.id_paramtable%TYPE,
   temp_id_pi_instance   t_pl_map.id_pi_instance%TYPE,
   temp_id_sub           t_pl_map.id_sub%TYPE,
   temp_id_acc           t_pl_map.id_acc%TYPE,
   temp_id_po            t_pl_map.id_po%TYPE,
   p_systemdate          DATE
)
AS
   temp_id_pi_type              INT;
   temp_currency                NVARCHAR2 (10);
   temp_id_pricelist            INT;
   temp_id_pi_template          INT;
   temp_id_pi_instance_parent   INT;
   temp_id_partition		    INT;
BEGIN
   BEGIN
      SELECT id_pi_type, id_pi_template, id_pi_instance_parent
        INTO temp_id_pi_type, temp_id_pi_template, temp_id_pi_instance_parent
        FROM t_pl_map
       WHERE id_pi_instance = temp_id_pi_instance AND id_paramtable IS NULL;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
   END;

   BEGIN
      SELECT pl.nm_currency_code
        INTO temp_currency
        FROM t_po po INNER JOIN t_pricelist pl
             ON po.id_nonshared_pl = pl.id_pricelist
       WHERE po.id_po = temp_id_po;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
   END;
   
   BEGIN
      SELECT po.c_POPartitionId
        INTO temp_id_partition
        FROM t_po po 
       WHERE po.id_po = temp_id_po;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
   END;

   INSERT INTO t_base_props
               (id_prop, n_kind, n_name, n_display_name, n_desc)
        VALUES (seq_t_base_props.NEXTVAL, 150, 0, 0, 0);

   SELECT seq_t_base_props.CURRVAL
     INTO temp_id_pricelist
     FROM DUAL;

   INSERT INTO t_pricelist
			   (id_pricelist,n_type,nm_currency_code,c_PLPartitionId)
        VALUES (temp_id_pricelist, 0, temp_currency, temp_id_partition);

   INSERT INTO t_pl_map
               (id_paramtable, id_pi_type, id_pi_instance,
                id_pi_template, id_pi_instance_parent, id_sub,
                id_po, id_pricelist, b_canicb, dt_modified
               )
        VALUES (temp_id_paramtable, temp_id_pi_type, temp_id_pi_instance,
                temp_id_pi_template, temp_id_pi_instance_parent, temp_id_sub,
                temp_id_po, temp_id_pricelist, 'N', p_systemdate
               );
END;
		  