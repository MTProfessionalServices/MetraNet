
CREATE OR REPLACE PROCEDURE addownedfolder (
   owner                        IN       INT,
   folder                       IN       INT,
   p_systemdate                 IN       DATE,
   p_enforce_same_corporation   IN       VARCHAR2,
   existing_owner               OUT      INT,
   status                       OUT      INT
)
AS
   bfolder   CHAR;
BEGIN
   status := 0;

   IF owner = folder
   THEN /*MT_FOLDER_CANNOT_OWN_ITSELF */
      status := -486604761;
      RETURN;
   END IF;

   BEGIN
      FOR i IN (SELECT id_owner
                  FROM t_impersonate
                 WHERE id_acc = folder)
      LOOP
         existing_owner := i.id_owner;
      END LOOP;

      IF existing_owner IS NULL
      THEN
         existing_owner := 0;
      END IF;

      IF existing_owner <> 0 AND existing_owner <> owner
      THEN /* the folder is already owned by another account           MT_EXISTING_FOLDER_OWNER*/
         status := -486604779;
         RETURN;
      END IF;
   END; /* simply exit the stored procedure if the current owner is the owner*/

   IF existing_owner = owner
   THEN
      status := 1;
      RETURN;
   END IF; /* check that both the payer and Payee are in the same corporate account*/

   IF     p_enforce_same_corporation = '1'
      AND dbo.isinsamecorporateaccount (owner, folder, p_systemdate) <> 1
   THEN /* MT_CANNOT_OWN_FOLDER_IN_DIFFERENT_CORPORATE_ACCOUNT*/
      status := -486604751;
      RETURN;
   END IF;

   IF existing_owner = 0
   THEN
      INSERT INTO t_impersonate
                  (id_owner, id_acc
                  )
           VALUES (owner, folder
                  );
   END IF; /*done*/

   status := 1;
END;
		 