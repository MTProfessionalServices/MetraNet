
          if exists (select * from sysobjects where id = object_id('dbo.t_ddo_messages'))
          begin
              truncate table t_ddo_messages
          end
          else
     			begin
              create table t_ddo_messages([Id] [int] IDENTITY(1,1) NOT NULL, [Message] [nvarchar] (255) NOT NULL)
          end
		  