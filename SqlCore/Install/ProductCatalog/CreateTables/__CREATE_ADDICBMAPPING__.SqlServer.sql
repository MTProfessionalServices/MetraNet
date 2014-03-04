
			create proc AddICBMapping(
					@id_paramtable as int,
					@id_pi_instance as int,
					@id_sub as int,
					@id_acc as int,
					@id_po as int,					
					@p_systemdate as datetime)
				as
					declare @id_pi_type as int
					declare @id_pricelist as int
					declare @id_pi_template as int
					declare @id_pi_instance_parent as int
					declare @currency as nvarchar(10)
					declare @partitionId as int
					
					select 	@id_pi_type = id_pi_type,
							@id_pi_template = id_pi_template,
							@id_pi_instance_parent = id_pi_instance_parent
					from t_pl_map 
					where id_pi_instance = @id_pi_instance AND id_paramtable is NULL

					--CR 10884 fix: get the price list currency from product catalog, not
					--corporation. This will take care of the case when gsubs are generated "globally".
					--Also, this seems to be correct for all other cases as well
					
					set @currency = (select pl.nm_currency_code 
									from t_po po
									inner join t_pricelist pl on po.id_nonshared_pl = pl.id_pricelist
									where po.id_po = @id_po)
					
					set @partitionId = (select po.c_POPartitionId 
										from t_po po
										where po.id_po = @id_po)

					insert into t_base_props (n_kind,n_name,n_display_name,n_desc) values (150,0,0,0)
					
					set @id_pricelist = @@identity
					
					insert into t_pricelist
						(id_pricelist,n_type,nm_currency_code,c_PLPartitionId)
						values (@id_pricelist, 0, @currency, @partitionId)
					
					insert into t_pl_map(
					  id_paramtable,
					  id_pi_type,
					  id_pi_instance,
					  id_pi_template,
					  id_pi_instance_parent,
					  id_sub,
					  id_po,
					  id_pricelist,
					  b_canICB,
					  dt_modified
					  )
					values(
					  @id_paramtable,
					  @id_pi_type,              
					  @id_pi_instance,
					  @id_pi_template,
					  @id_pi_instance_parent,
					  @id_sub,
					  @id_po,
					  @id_pricelist,
					  'N',
					  @p_systemdate
					  )
		