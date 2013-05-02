
				SELECT 
				*
				FROM 
				CI_INFOOBJECTS 
				WHERE 
				SI_PROGID = 'CrystalEnterprise.Report' 
				AND SI_NAME = '%%REPORT_TEMPLATE_NAME%%'
				AND SI_INSTANCE=0
				AND SI_PARENT_FOLDER = '%%METRANET_FOLDER_ID%%'
			