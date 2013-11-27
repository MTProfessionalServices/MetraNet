
insert into t_account_type (
	id_type, name, b_cansubscribe, b_canbepayer, b_canhavesyntheticroot,
	b_canparticipateingsub, b_isvisibleinhierarchy, b_canhavetemplates,
	b_iscorporate, nm_description
) values (
	1, 'Root', 0, 0, 0, 0, 1, 0, 0,
	'This is the root of the account hierarchy.  Only one account of root can exist.  Don''t customize.'
)

