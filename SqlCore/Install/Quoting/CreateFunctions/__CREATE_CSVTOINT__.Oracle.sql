
create or replace function csvtoint (p_id_instances varchar2)return tab_id_instance is
        v_tab_id_instance tab_id_instance:=tab_id_instance();
    begin
        if instr(p_id_instances,',',1) = 0 then
            v_tab_id_instance.extend(1);
            v_tab_id_instance(1) := to_number(p_id_instances);
            return v_tab_id_instance;
        elsif instr(p_id_instances,',',1) > 1 then
            v_tab_id_instance.extend(1);
            v_tab_id_instance(1) := to_number(substr(p_id_instances,1,instr(p_id_instances,',',1)-1));
            for i in 2..4000
            loop
                v_tab_id_instance.extend(1);
                if (instr(p_id_instances,',',1,i) > 0) then
                    v_tab_id_instance(i):= to_number( substr(p_id_instances,(instr(p_id_instances,',',1,i-1)+1),((instr(p_id_instances,',',1,i))-(instr(p_id_instances,',',1,i-1))-1)) );
                else
                    v_tab_id_instance(i):= to_number(substr(p_id_instances,(instr(p_id_instances,',',1,i-1)+1),length(p_id_instances)- instr(p_id_instances,',',1,i-1)));
                    exit;
                end if;
            end loop;
            return v_tab_id_instance;
        end if;
    end csvtoint;