
update t_session_state ss
   set ss.dt_end = (select fsss.dt_failuretime
                      from %%%NETMETERSTAGE_PREFIX%%%t_failed_session_state_stage fsss
                     where fsss.tx_failureid = ss.id_sess)
 where exists(select fsss.dt_failuretime
                from %%%NETMETERSTAGE_PREFIX%%%t_failed_session_state_stage fsss
               where fsss.tx_failureid = ss.id_sess)
   and ss.dt_end = %%MAX_DATE%%
       