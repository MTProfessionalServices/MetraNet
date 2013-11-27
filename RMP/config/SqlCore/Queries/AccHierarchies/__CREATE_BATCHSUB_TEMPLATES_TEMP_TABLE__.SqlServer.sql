
          IF OBJECT_ID('%%TMP_TABLE_NAME%%') IS NOT NULL DROP TABLE %%TMP_TABLE_NAME%%
          CREATE TABLE %%TMP_TABLE_NAME%%
          (
              -- Input Values - Required values are specified as NOT NULL.

              -- Account Related
              id_acc          int      NOT NULL ,
              id_ancestor     int      NOT NULL ,
              id_corporate    int      NOT NULL ,
              dt_acc_start    datetime NOT NULL ,
              dt_acc_end      datetime NOT NULL ,

              -- Ouput or Return Values

              -- Template Related
              id_acc_type     int NOT NULL,
              id_template     int      NULL
          )
        