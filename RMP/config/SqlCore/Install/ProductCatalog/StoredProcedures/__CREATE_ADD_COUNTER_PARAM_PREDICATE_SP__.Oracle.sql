
			CREATE OR REPLACE procedure AddCounterParamPredicate
									(
									p_id_counter_param t_counter_param_predicate.ID_COUNTER_PARAM%type,
									p_id_pv_prop t_counter_param_predicate.ID_PV_PROP%type,
								      p_nm_op t_counter_param_predicate.NM_OP%type,
									p_nm_value t_counter_param_predicate.NM_VALUE%type,
									p_ap_id_prop out t_counter_param_predicate.ID_PROP%type
									)
			AS
			BEGIN
			INSERT INTO t_counter_param_predicate
				(id_prop,id_counter_param, id_pv_prop, nm_op, nm_value)
			VALUES
				(seq_t_counter_param_predicate.nextval,p_id_counter_param, p_id_pv_prop, p_nm_op, p_nm_value);
			SELECT seq_t_counter_param_predicate.currval into p_ap_id_prop from dual;
			end;
	