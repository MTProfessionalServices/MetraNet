CREATE TABLE [dbo].[t_message_mapping]
( 
    [id_message] [int] NOT NULL, 
    [id_origin_message] [int] NOT NULL,
    CONSTRAINT [pk_t_message_mapping] PRIMARY KEY CLUSTERED  ( [id_origin_message])        
) 