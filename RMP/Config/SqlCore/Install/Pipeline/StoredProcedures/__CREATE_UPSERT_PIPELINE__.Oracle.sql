
CREATE or replace PROCEDURE UpsertPipeline (p_tx_machine nvarchar2, p_id_pipeline OUT int )
AS
BEGIN
      update t_pipeline 
			set 
			b_online = '1'
			where
			tx_machine = p_tx_machine;

			if (SQL%ROWCOUNT = 0) then
    		    insert into t_pipeline(id_pipeline,tx_machine, b_online, b_paused, b_processing) values (seq_t_pipeline.nextval,p_tx_machine, '1', '0', '0');
            end if;

			for i in (select id_pipeline from t_pipeline where tx_machine=p_tx_machine)
                        loop
                            p_id_pipeline := i.id_pipeline;
                        end loop;
END;
			