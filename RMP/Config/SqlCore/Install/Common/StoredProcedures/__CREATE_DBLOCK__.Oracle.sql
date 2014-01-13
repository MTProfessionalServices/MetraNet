
        CREATE OR REPLACE procedure DBLOCK
(p_lockname in varchar2,
 p_timeout in integer,
 p_lockmode in varchar2,
 p_result out integer
)
authid current_user
is
   PRAGMA AUTONOMOUS_TRANSACTION;
   v_lockhandle   VARCHAR2 (200);
   v_result       NUMBER;
BEGIN

   v_result := -1;

   /* DBMS_OUTPUT.put_line ('p_lockname   = '  || p_lockname); */
   /* DBMS_OUTPUT.put_line ('v_lockhandle = '  || v_lockhandle); */
   /* DBMS_OUTPUT.put_line ('p_timeout    = '  || p_timeout); */
   /* DBMS_OUTPUT.put_line ('p_lockmode   = '  || p_lockmode); */

   /* allocate the lock based on p_lockname  */
   DBMS_LOCK.allocate_unique (p_lockname, v_lockhandle);

   IF p_lockmode = 'RELEASE'  THEN
        /* DBMS_OUTPUT.put_line ('Releasing Lock'); */
        v_result := DBMS_LOCK.RELEASE (v_lockhandle);

        DBMS_OUTPUT.put_line (CASE
                               WHEN v_result = 0
                                  THEN 'Lock Released'
                               WHEN v_result = 3
                                  THEN 'Parameter Error'
                               WHEN v_result = 4
                                  THEN 'Do not own lock specified by id or lockhandle'
                               WHEN v_result = 5
                                  THEN 'Illegal Lock Handle'
                            END
                          || (' V_Result = ' || v_result));
   else
	      /* get the lock based on lockhandle */
        /* DBMS_OUTPUT.put_line ('Acquiring Lock'); */
       v_result := DBMS_LOCK.request (v_lockhandle, DBMS_LOCK.x_mode, p_timeout);

       DBMS_OUTPUT.put_line (CASE
                               WHEN v_result = 0
                                  THEN 'Lock Allocated'
                               WHEN v_result = 1
                                  THEN 'Timeout'
                               WHEN v_result = 2
                                  THEN 'Deadlock'
                               WHEN v_result = 3
                                  THEN 'Parameter Error'
                               WHEN v_result = 4
                                  THEN 'Already owned'
                               WHEN v_result = 5
                                  THEN 'Illegal Lock Handle'
                            END
                             || (' V_Result = ' || v_result));
  end if;

 /* set the return value */
 p_result := v_result;
END DBLOCK;
			