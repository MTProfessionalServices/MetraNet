
          CREATE TABLE t_failed_transaction (
          id_failed_transaction int NOT NULL ,
          State char (1)  NOT NULL ,
          tx_StateReasonCode nvarchar (255),
          tx_FailureID varbinary (16),
          tx_FailureID_Encoded nvarchar (30)  NOT NULL ,
          tx_FailureCompoundID varbinary (16),
          tx_FailureCompoundID_encoded nvarchar (30)  NOT NULL ,
          id_PossiblePayeeID int NOT NULL ,
          id_PossiblePayerID int NOT NULL DEFAULT '-1',
          tx_FailureServiceName nvarchar (64)  NOT NULL ,
          n_Code int NOT NULL ,
          n_Line int NOT NULL ,
          dt_FailureTime datetime NOT NULL ,
          dt_MeteredTime datetime NOT NULL ,
          tx_Sender nvarchar (30)  NOT NULL ,
          tx_ErrorMessage nvarchar (1024)  NOT NULL ,
          tx_StageName nvarchar (64)  NOT NULL ,
          tx_PlugIn nvarchar (64)  NOT NULL ,
          tx_Module nvarchar (255)  NOT NULL ,
          tx_Method nvarchar (64)  NOT NULL ,
          tx_Batch varbinary (16),
          tx_Batch_Encoded nvarchar (30),
          b_compound char (1) NOT NULL,
          tx_errorcodemessage nvarchar (255) NOT NULL,
          id_sch_ss int null,
          dt_StateLastModifiedTime datetime NOT NULL,
          dt_Start_Resubmit datetime2(7),
          resubmit_Guid uniqueidentifier,
          CONSTRAINT PK_t_failed_transaction PRIMARY KEY CLUSTERED (id_failed_transaction)
          )
          CREATE NONCLUSTERED INDEX tx_FailureCompoundID_idx ON t_failed_transaction(tx_FailureCompoundID)
          CREATE INDEX t_failed_transaction_batch_idx ON t_failed_transaction(tx_batch_encoded)
          CREATE NONCLUSTERED INDEX t_failed_transaction_id_sch_ss ON t_failed_transaction(id_sch_ss)
        