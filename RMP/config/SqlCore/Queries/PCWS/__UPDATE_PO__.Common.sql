
                update t_po set
                b_user_subscribe = '%%CAN_SUBSCRIBE%%',
                b_user_unsubscribe = '%%CAN_UNSUBSCRIBE%%',
	        b_hidden = '%%IS_HIDDEN%%', -- ESR-4293
     			c_POPartitionId = %%POPARTITIONID%%
                where id_po = %%ID_PO%%
            