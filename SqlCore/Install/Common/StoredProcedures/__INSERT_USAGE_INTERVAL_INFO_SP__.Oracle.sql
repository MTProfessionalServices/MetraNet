
    create procedure InsertUsageIntervalInfo (p_dt_start IN varchar2,
        p_dt_end IN varchar2, p_id_usage_cycle IN int, p_id_interval OUT int)
    as
        startdate date := TO_DATE(p_dt_start, 'MM/DD/YYYY');
        enddate   date := TO_DATE(p_dt_end, 'MM/DD/YYYY HH24:MI:SS');
    begin
        for i in (select id_interval from
        t_pc_interval pc where pc.id_cycle = p_id_usage_cycle AND
        pc.dt_start = startdate AND pc.dt_End = enddate)
        loop
            p_id_interval := i.id_interval;
        end loop;
        insert into t_usage_interval (id_interval, dt_start, dt_end,
        id_usage_cycle, tx_interval_status) values
        (p_id_interval,startdate,enddate,p_id_usage_cycle, 'N');
        if SQL%ROWCOUNT <> 1 then
            p_id_interval := -99;
        end if;
    exception
    when others then
        p_id_interval := -99;
    end;
          