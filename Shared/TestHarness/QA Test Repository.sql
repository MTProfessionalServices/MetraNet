
TEST HARNESS WORK FLOW
	[0] The test harness option dialog tab QATestRepository
	
	[1] Create a new feature call Register Session into the QATestRepository
		one dialog ask the user for
			+ a description (different from the one in the test database)
			+ Total cases	
			+ Engineer
	
sp_help t_test 
	id_test
	tx_description
	nm_automation
	ct_total_cases
	id_test_owner
	id_automation

sp_help t_engineers
select* from  t_engineers
	

sp_help t_test_run
	id_run
	id_test
	id_build
	dt_run
	id_engineer
	ct_failed_cases
	tx_status
	tx_comments
	id_system
	tx_bugs


