/* ***** DELETES Stale Templates ***** */
DELETE FROM t_be_cor_cre_creditnotetmpl 
WHERE c_TemplateName NOT IN (%%ExistingTemplates%%)