
CREATE TABLE t_approvals
(
	id_approval               INT NOT NULL,
	c_SubmittedDate           date DEFAULT sysdate NULL,
	c_SubmitterId             number(10) NOT NULL,
	c_ChangeType              varchar2(100) NOT NULL,
	c_ChangeDetails           BLOB NOT NULL,
	c_ApproverId              number(10) NULL,
	c_ChangeLastModifiedDate  date NULL,
	c_ItemDisplayName         varchar2(100) NULL,
	c_UniqueItemId            varchar2(100) NULL,
	c_Comment                 varchar2(255) NULL,
	c_CurrentState            varchar2(50) NOT NULL,
	c_PartitionId             number(10) DEFAULT 1 NOT NULL,
	CONSTRAINT PK_t_approvals PRIMARY KEY(id_approval)
)
