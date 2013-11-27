
and not exists
(
  /* don't consider messages if an associated service
      def is marked with 'noresubmit' */
  select *
  from t_session_set ss %%%READCOMMITTED%%%
  where 
    ss.id_message = msg.id_message AND
    ss.id_svc IN (%%NORESUBMIT_LIST%%)
)
			