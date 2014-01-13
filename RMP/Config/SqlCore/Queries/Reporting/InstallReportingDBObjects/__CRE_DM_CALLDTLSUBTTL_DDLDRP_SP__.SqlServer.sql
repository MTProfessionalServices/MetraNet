
CREATE PROCEDURE mtsp_dm_calldtlsubttl_ddldrp
AS
BEGIN
	-- Summary table for t_account_ancestor for reporting
	IF EXISTS (SELECT NULL FROM sysobjects WHERE id = object_id('dm_t_sum_gen1') 
			AND OBJECTPROPERTY (id, 'IsTable') = 1)
		DROP TABLE dm_t_sum_gen1

	IF EXISTS (SELECT NULL FROM sysobjects WHERE id = object_id('dm_t_sum_acc_gen_flat') 
			AND OBJECTPROPERTY (id, 'IsTable') = 1)
		DROP TABLE dm_t_sum_acc_gen_flat

	IF EXISTS (SELECT NULL FROM sysobjects WHERE id = object_id('dm_t_sum_acc_gen_flat_s1') 
			AND OBJECTPROPERTY (id, 'IsTable') = 1)
		DROP TABLE dm_t_sum_acc_gen_flat_s1

	IF EXISTS (SELECT NULL FROM sysobjects WHERE id = object_id('dm_t_sum_acc_lvl_flat') 
			AND OBJECTPROPERTY (id, 'IsTable') = 1)
		DROP TABLE dm_t_sum_acc_lvl_flat

	-- drop the report result data table
	IF EXISTS (SELECT NULL FROM sysobjects WHERE id = object_id('dm_t_rptrst_calldtl_detail') 
			AND OBJECTPROPERTY (id, 'IsTable') = 1)
		DROP TABLE dm_t_rptrst_calldtl_detail

	-- drop the report result parent table
	IF EXISTS (SELECT NULL FROM sysobjects WHERE id = object_id('dm_t_rptrst_calldtl_parent') 
			AND OBJECTPROPERTY (id, 'IsTable') = 1)
		DROP TABLE dm_t_rptrst_calldtl_parent
END
	   