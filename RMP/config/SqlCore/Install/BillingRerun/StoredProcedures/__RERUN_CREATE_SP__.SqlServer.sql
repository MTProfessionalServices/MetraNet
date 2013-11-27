
      create procedure ReRunCreate(@tx_filter nvarchar(255),
			  @id_acc int,
			  @tx_comment nvarchar(255),
			  @dt_system_date datetime,
			  @id_rerun int output)
      as
      insert into t_rerun (tx_filter, tx_tag) values(@tx_filter, null)
      set @id_rerun = @@identity

      insert into t_rerun_history (id_rerun, dt_action, tx_action,
		    id_acc, tx_comment)
	      values (@id_rerun, @dt_system_date, 'CREATE', @id_acc,
		    @tx_comment)

    