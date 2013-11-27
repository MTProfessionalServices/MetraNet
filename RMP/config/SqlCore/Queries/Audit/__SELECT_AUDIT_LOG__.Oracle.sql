
				select * from
				(
        select * from vw_audit_log order by Time DESC
        )
        where rownum < 1001 
        