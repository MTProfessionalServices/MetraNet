
        CREATE OR REPLACE PROCEDURE addbillmanager (
           managee                        IN       INT,
           manager                       IN       INT,
           p_systemdate                 IN       DATE,
           p_enforce_same_corporation   IN       VARCHAR2,
           status                       OUT      INT
        )
        AS
           existing_manager   INT;
        BEGIN
           status := 0;

           IF managee = manager
           THEN /*MT_manager_CANNOT_OWN_ITSELF */
              status := 2;
              RETURN;
           END IF;

           BEGIN

              FOR i IN (SELECT id_manager
                          FROM t_bill_manager
                         WHERE id_acc = managee and id_manager = manager)
              LOOP
                 existing_manager := i.id_manager;
              END LOOP;

              IF existing_manager IS NULL
              THEN
                 existing_manager := 0;
              END IF;

            END; 
            /* simply exit the stored procedure if the current managee is the managee*/

           IF existing_manager = manager
           THEN
              status := 1;
              RETURN;
           END IF; /* check that both the payer and Payee are in the same corporate account*/

           IF     p_enforce_same_corporation = '1'
              AND dbo.isinsamecorporateaccount (managee, manager, p_systemdate) <> 1
           THEN /* MT_CANNOT_OWN_manager_IN_DIFFERENT_CORPORATE_ACCOUNT*/
              status := 3;
              RETURN;
           END IF;

           IF existing_manager = 0
           THEN
              INSERT INTO t_bill_manager
                          (id_manager, id_acc
                          )
                   VALUES (manager, managee
                          );
           END IF; /*done*/

           status := 0;
        END;
      