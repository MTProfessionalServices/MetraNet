
		create or replace procedure ExecSpProcOnKind
        (kind t_principals.ID_PRINCIPAL%type,id int)
				as
        c1 pls_integer;
        ret pls_integer;
				sprocname varchar(256);
        begin
	    		for i in (
                select 'begin'||' '||nm_sprocname||'(:ss)'||'; end;' sprocnam from t_principals where id_principal = kind )
                loop
                    sprocname := i.sprocnam;
                end loop;
					c1 := DBMS_SQL.OPEN_CURSOR;
          DBMS_SQL.PARSE(C1,sprocname,dbms_sql.v7);
          DBMS_SQL.BIND_VARIABLE(c1,'ss',id);
          ret := DBMS_SQL.EXECUTE(c1);
          DBMS_SQL.CLOSE_CURSOR(c1);
        end;  
	 