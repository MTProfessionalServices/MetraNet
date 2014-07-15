
	create proc [dbo].[GetICBMappingForSub]	(
  	@id_paramtable as int,
    @id_pi_instance as int,
    @id_sub as int,
    @p_systemdate as datetime,
    @status as int output,
    @id_pricelist as int output)
	as
		declare @id_pi_type as int
		declare @id_pi_template as int
		declare @id_pi_instance_parent as int
		declare @currency as nvarchar(10)
		declare @id_po as int
		declare @partitionId as int
					
		set @status = 0
					
		select 
			@id_pi_type = id_pi_type,
			@id_pi_template = id_pi_template,
			@id_pi_instance_parent = id_pi_instance_parent
		from 
			t_pl_map with(updlock) 
		where id_pi_instance = @id_pi_instance and id_paramtable is NULL

		--CR 10884 fix: get the price list currency from product catalog, not
		--corporation. This will take care of the case when gsubs are generated "globally".
		--Also, this seems to be correct for all other cases as well
					
		select 
			@currency = pl.nm_currency_code, 
			@id_po = po.id_po, 
			@partitionId = po.c_POPartitionId
		from t_po po
			inner join t_pricelist pl with(updlock) on po.id_nonshared_pl = pl.id_pricelist
			inner join t_sub s on po.id_po = s.id_po
		where s.id_sub = @id_sub

		select @id_pricelist = id_pricelist 
		from t_pl_map with(updlock)
		where id_sub = @id_sub and id_pi_instance = @id_pi_instance and id_paramtable = @id_paramtable
								
			if(@@ROWCOUNT = 0)								
			BEGIN
				if exists(select id_pricelist from t_pl_map where
									id_po = @id_po and id_pi_instance = @id_pi_instance and
									id_paramtable = @id_paramtable and
									id_sub is null and id_acc is null and 
									B_CANICB = 'Y') 
				BEGIN
					insert into t_base_props (n_kind,n_name,n_display_name,n_desc) values (150,0,0,0)
					set @id_pricelist = @@identity
					insert into t_pricelist(id_pricelist, n_type, nm_currency_code, c_PLPartitionId) 
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
					  @p_systemdate)
				END
				ELSE
				BEGIN
					set @status = -10
				END
			END
			