
        update t_po set 
          b_user_subscribe = '%%CAN_SUBSCRIBE%%',
          b_user_unsubscribe = '%%CAN_UNSUBSCRIBE%%',
          b_hidden = '%%IS_HIDDEN%%',
          id_nonshared_pl = %%ID_NONSHARED_PL%%,
		  c_POPartitionId = %%POPARTITIONID%%
        where id_po = %%ID_PO%%
      