CREATE OR REPLACE
function determine_absolute_dates(v_date DATE, my_date_type NUMBER, my_date_offset NUMBER, my_id_acc NUMBER, is_start NUMBER) return DATE
as
my_date DATE;
my_acc_start DATE;
curr_id_cycle_type NUMBER;
curr_day_of_month NUMBER;
my_cycle_cutoff DATE;
begin
    my_date := v_date;
    IF (my_date_type = 1 AND my_date IS NOT NULL) THEN
        return my_date;
    END IF;
    IF (my_date_type = 4 or (my_date_type = 1 and my_date IS NULL)) THEN
        IF (is_start = 1) THEN
            IF (my_id_acc IS NOT NULL AND my_id_acc > 0) THEN
                select dt_crt into my_date from t_account where id_acc = my_id_acc;
            ELSE
                select mtmindate() into my_date from dual;
            END IF;
        ELSE
            select mtmaxdate() into my_date from dual;
        END IF;
        return my_date;
    END IF;
    IF (my_date_type = 3) THEN
        select dt_crt into my_acc_start from t_account where id_acc = my_id_acc;
        IF (my_acc_start > my_date or my_date IS NULL) THEN
            my_date := my_acc_start;
        END IF;
        select id_cycle_type, day_of_month into curr_id_cycle_type, curr_day_of_month
            from t_acc_usage_cycle a, t_usage_cycle b
            where a.id_usage_cycle = b.id_usage_cycle and a.id_acc = my_id_acc;
        IF (curr_id_cycle_type = 1) THEN
            select trunc(my_date,'MM') + decode(curr_day_of_month,31,0,curr_day_of_month) into my_cycle_cutoff from dual;
            IF (my_date > my_cycle_cutoff) THEN
                select add_months(my_date, 1) into my_cycle_cutoff from dual;
            END IF;
            my_date := my_cycle_cutoff;
            select my_date + my_date_offset into my_date from dual;
        END IF;
        return my_date;
    END IF;
    return my_date;
end determine_absolute_dates;

