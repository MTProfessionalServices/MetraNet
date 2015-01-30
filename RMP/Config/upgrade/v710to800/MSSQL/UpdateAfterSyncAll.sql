
DECLARE @tmpEnumValNone [int] = -1;
DECLARE @tmpEnumValInprogress [int] = -1;
DECLARE @tmpEnumValFailed [int] = -1;
DECLARE @tmpEnumValCompleted [int] = -1;

SELECT @tmpEnumValNone = id_enum_data FROM t_enum_data WHERE nm_enum_data = 'metratech.com/QuoteStatus/None';
SELECT @tmpEnumValInprogress = id_enum_data FROM t_enum_data WHERE nm_enum_data = 'metratech.com/QuoteStatus/InProgress';
SELECT @tmpEnumValFailed = id_enum_data FROM t_enum_data WHERE nm_enum_data = 'metratech.com/QuoteStatus/Failed';
SELECT @tmpEnumValCompleted = id_enum_data FROM t_enum_data WHERE nm_enum_data = 'metratech.com/QuoteStatus/Complete';

UPDATE t_be_cor_qu_quoteheader SET c_status = @tmpEnumValNone WHERE c_status = 0;
UPDATE t_be_cor_qu_quoteheader SET c_status = @tmpEnumValInprogress WHERE c_status = 1;
UPDATE t_be_cor_qu_quoteheader SET c_status = @tmpEnumValFailed WHERE c_status = 2;
UPDATE t_be_cor_qu_quoteheader SET c_status = @tmpEnumValCompleted WHERE c_status = 3;
