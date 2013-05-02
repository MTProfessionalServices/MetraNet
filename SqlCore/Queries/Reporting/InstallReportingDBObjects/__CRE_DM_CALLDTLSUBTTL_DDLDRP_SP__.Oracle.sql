
create or replace procedure mtsp_dm_calldtlsubttl_ddldrp
as
begin

	/* summary table for t_account_ancestor for reporting */
	if table_exists('dm_t_sum_gen1') then 
		execute immediate ('drop table dm_t_sum_gen1');
	end if;

	if table_exists('dm_t_sum_acc_gen_flat') then 
		execute immediate ('drop table dm_t_sum_acc_gen_flat');
	end if;

	if table_exists('dm_t_sum_acc_gen_flat_s1')1 then 
		execute immediate ('drop table dm_t_sum_acc_gen_flat_s1');
	end if;

	if table_exists('dm_t_sum_acc_lvl_flat')1 then 
		execute immediate ('drop table dm_t_sum_acc_lvl_flat');
	end if;

	/* drop the report result data table */
	if table_exists('dm_t_rptrst_calldtl_detail') then 
		execute immediate ('drop table dm_t_rptrst_calldtl_detail');
	end if;

	/* drop the report result parent table */
	if table_exists('dm_t_rptrst_calldtl_parent') then 
		execute immediate ('drop table dm_t_rptrst_calldtl_parent');
	end if;

	/* drop the report sequence */
	if object_exists('seq_dm_rpt_calldtl') then 
		execute immediate ('drop sequence seq_dm_rpt_calldtl');
	end if;

end mtsp_dm_calldtlsubttl_ddldrp;
	   