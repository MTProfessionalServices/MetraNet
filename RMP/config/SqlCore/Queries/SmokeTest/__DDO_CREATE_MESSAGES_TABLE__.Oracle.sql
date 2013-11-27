
        begin
          if table_exists('t_ddo_messages') then
            exec_ddl ('truncate table t_ddo_messages');
          else
            execute immediate ('create table t_ddo_messages(Id number(10) NOT NULL, Message nvarchar2(255) NOT NULL)');
            execute immediate ('create sequence seq_tmp_t_ddo_messages start with 1 increment by 1 nocycle');
          end if;
        end;
		  