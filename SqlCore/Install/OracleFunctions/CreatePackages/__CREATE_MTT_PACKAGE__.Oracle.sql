
          CREATE OR REPLACE PACKAGE mt_ttt
            AS
	            function get_tx_id ( p_create_transaction BOOLEAN := FALSE ) 
	            return varchar2;

            END mt_ttt;
				