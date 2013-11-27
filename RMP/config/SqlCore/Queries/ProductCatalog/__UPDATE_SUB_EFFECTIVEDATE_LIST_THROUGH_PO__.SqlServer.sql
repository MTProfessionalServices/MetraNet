
				    declare	@varMaxDateTime as datetime
						declare @varSystemGMTDateTime as datetime 
          
					  select @varSystemGMTDateTime = %%%SYSTEMDATE%%%
						select @varMaxDateTime = dbo.MTMaxDate()
						update 
							t_sub 
						set 
							vt_end = %%END_DATE%% 
						where
							id_po = %%ID_PO%% AND 
							vt_end >= %%END_DATE%%

						update 
							t_sub_history 
						set 
							tt_end = dateadd(s,-1,@varSystemGMTDateTime) 
         		where
							id_po = %%ID_PO%% AND 
							vt_end >= %%END_DATE%% and 
							tt_end = @varMaxDateTime
       

            insert into 
            	t_sub_history (id_sub,	
 							id_sub_Ext,
              id_Acc,
              id_po,
              dt_crt,
              id_group,
              vt_start,
							vt_end,
							tt_start,
							tt_end)
 						select 	
 							id_sub,	
 							id_sub_Ext,
              id_Acc,
              id_po,
              dt_crt,
              id_group,
              vt_start,
              %%END_DATE%%,
              @varSystemGMTDateTime,
              @varMaxDateTime 
            from
							t_sub_history 
						where 
              id_po = %%ID_PO%% AND 
              vt_end >= %%END_DATE%% and 
              tt_end = dateadd(s,-1,@varSystemGMTDateTime)
              
							