
        insert into t_po (id_po,id_eff_date,id_avail,b_user_subscribe,b_user_unsubscribe,id_nonshared_pl, b_hidden,c_POPartitionId) values 
        (%%ID_PO%%,%%ID_EFF_DATE%%,%%ID_AVAIL%%,'%%CAN_SUBSCRIBE%%','%%CAN_UNSUBSCRIBE%%',%%ID_NONSHARED_PL%%, '%%IS_HIDDEN%%',%%POPARTITIONID%%)
      