using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace MetraTech.Product.Hooks
{
    /// <summary>
    /// Containc common constants
    /// </summary>
    public static class Common
    {
        /// <summary>
        /// Gets path to Query folder
        /// </summary>
        public const string QueryPath = "Queries";

        /// <summary>
        /// Gets path to ServiceDef folder, for example Queries\ServiceDef
        /// </summary>
        public static readonly string ServiceDefQueryPath = Path.Combine(QueryPath, "ServiceDef");

        /// <summary>
        /// Gets path to Account folder, for example Queries\Account
        /// </summary>
        public static readonly string AccountQueryPath = Path.Combine(QueryPath, "Account");

        public const string NetMeterDb = "NetMeter";

        public const string NetMeterStageDb = "NetMeterStage";

        public const string ServDefPrefix = "t_svc_";

        #region Constants from AdapterQuery

        public const string DatabaseNameParam = "%%DATABASE_NAME%%";

        public const string TableNameParam = "%%TABLE_NAME%%";

        public const string ColumnNameParam = "%%COLUMN_NAME%%";

        public const string AdditionalColumnsParam = "%%ADDITIONAL_COLUMNS%%";

        public const string ReservedColumnsParam = "%%RESERVED_COLUMNS%%";

        public const string TableDescriptionParam = "%%TABLE_DESCRIPTION%%";

        public const string CreateTableDescriptionParam = "%%CREATE_TABLE_DESCRIPTION%%";

        public const string ColumnDescriptionParam = "%%COLUMN_DESCRIPTION%%";

        public const string CreateColumnsDescriptionParam = "%%CREATE_COLUMNS_DESCRIPTION%%";

        public const string SdfNameParam = "%%SDEF_NAME%%";

        public const string NameSpaceParam = "%%NAME_SPACE%%";

        public const string AccViewNameParam = "%%ACCOUNT_VIEW_NAME%%";
        
        public const string IndexSuffixParam = "%%INDEX_SUFFIX%%";

        public const string IndexColumnParam = "%%INDEX_COLUMNS%%";

        public const string FkNameParam = "%%FK_NAME%%";

        public const string AccViewColumnNameParam = "%%AV_COLUMN_NAME%%";

        public const string PartOfKeyParam = "%%PART_OF_KEY%%";

        public const string ForiegnTableParam = "%%FORIEGN_TABLE%%";

        public const string ForiegnColumnParam = "%%FORIEGN_COLUMN%%";

        public const string ForiegnConstrainsParam = "%%FOREIGN_CONSTRAINS%%";

        public const string SingleIndexesParam = "%%SINGLE_INDEXES%%";

        public const string CompositeIndexesParam = "%%COMPOSITE_INDEXES%%";

        public const string IdPartitionDefaultValue = "%%DEFAULT_VALUE%%";

      #endregion Constants from AdapterQuery

    }
}
