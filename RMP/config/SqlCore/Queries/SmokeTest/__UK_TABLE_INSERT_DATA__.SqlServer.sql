
		DECLARE @new_id_sess BIGINT
		
		SELECT @new_id_sess = ISNULL(MAX(id_sess), 0) + 1 FROM %%UK_TABLE_NAME%%

		INSERT INTO %%UK_TABLE_NAME%%
		  (
			id_sess,
			id_usage_interval,
			c_quantity,
			c_ordertime,
			c_price,
			c_broker
		  )
		VALUES
		  (
			@new_id_sess,
			0,
			%%TEST_QUANTITY%%,
			%%TEST_ORDER_TIME%%,
			%%TEST_PRICE%%,
			'%%TEST_BROKER%%'
		  )
		