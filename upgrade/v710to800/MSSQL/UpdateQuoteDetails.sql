PRINT N'Updating detail fields [dbo].[t_be_cor_qu_quoteheader]'
GO
UPDATE dbo.t_be_cor_qu_quoteheader 
SET
  c_GroupSubscription = 'F',
  c_AccountsInfo = (
    SELECT STUFF(
      CAST(
        (
          SELECT [text()] = ', ' + CAST(c_AccountID AS VARCHAR(50))
          FROM t_be_cor_qu_accountforquote ac
          WHERE ac.c_QuoteHeader_Id = qh.c_QuoteHeader_Id
          FOR XML PATH(''), TYPE
        ) AS VARCHAR(2000)
      ), 
      1, 2, ''
    )
  ),
  c_POsInfo = (
    SELECT STUFF(
      CAST(
        (
          SELECT [text()] = ', ' + CAST(c_POID AS VARCHAR(50))
          FROM t_be_cor_qu_poforquote po
          WHERE po.c_QuoteHeader_Id = qh.c_QuoteHeader_Id
          FOR XML PATH(''), TYPE
        ) AS VARCHAR(2000)
      ), 
      1, 2, ''
    )
  )
FROM dbo.t_be_cor_qu_quoteheader qh;
GO