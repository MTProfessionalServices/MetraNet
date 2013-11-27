
        SELECT * FROM t_tax_input_%%RUN_ID%% INNER JOIN t_tax_output_%%RUN_ID%% 
        ON t_tax_input_%%RUN_ID%%.id_tax_charge=t_tax_output_%%RUN_ID%%.id_tax_charge ORDER BY id_acc
      