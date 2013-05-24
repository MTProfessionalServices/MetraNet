using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.BusinessEntity.DataAccess.Common
{
    public static class SqlCommands
    {
        public const string MsSqlTableDescription =
            @"EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'{0}',
                                              @level0type=N'SCHEMA',@level0name=N'dbo', 
                                              @level1type=N'TABLE',@level1name=N'{1}'";

        public const string OracleTableDescription = "COMMENT ON TABLE {0} IS'{1}'";

        public const string MsSqlColumnDescription =
            @"EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value='{0}',
                                              @level0type=N'SCHEMA',@level0name=N'dbo', 
                                              @level1type=N'TABLE',@level1name='{1}', 
                                              @level2type=N'COLUMN',@level2name='{2}'";
       
        public const string OracleColumnDescription = "COMMENT ON COLUMN {0}.{1} IS'{2}'";

        public const string BmeIdDescription = "Identifier for Business Model Entity";
        public const string BmeVersionDescription = "Version of Business Model Entity";
        public const string BmeInternalKeyDescription = "Internal key for Business Model Entity";
        public const string BmeCreationDateDescription = "Date of creation Business Model Entity";
        public const string BmeUpdateDateDescription = "Date of update Business Model Entity";
        public const string BmeUIDDescription = "User Id";
    }
}
