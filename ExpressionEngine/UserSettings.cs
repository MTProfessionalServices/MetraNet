using MetraTech.ExpressionEngine.Expressions.Constants;

namespace MetraTech.ExpressionEngine
{
    /// <summary>
    /// This should be moved to the GUI layer in the future. Since most objects have a few properties that implemenet
    /// IExpressionEngineTreeNode this needs to be in this project. When those are moved, this should also move.
    /// 
    /// Options that are set on a per-user basis. Afftects how the ExpressionEngine GUI behaves.
    /// </summary>
    public class UserSettings
    {
        #region Properties
        /// <summary>
        /// Indicates if the new (i.e., EVENT.Timestamp) or old (i.e, USAGE.c_Timestamp) syntax should be used. In the future
        /// this will be driven off of the CDE version number and will not be a user option
        /// </summary>
        public bool NewSyntax { get; set; }

        /// <summary>
        /// The equality operator syntax used when generating snippets in the editor
        /// </summary>
        public string DefaultEqualityOperator { get; set; }

        /// <summary>
        /// The inequality operator syntax used when generating snippets in the editor
        /// </summary>
        public string DefaultInequalityOperator { get; set; }

        /// <summary>
        /// Indicates if inserted text should be automatically selected. For example, if the user double clicks on a 
        /// function in the tree should the text that's inserted be automatically selected. 
        /// </summary>
        public bool AutoSelectInsertedSnippets { get; set; }

        /// <summary>
        /// Indicates if the acutual database mappings should be shown in tooltips. This is useful in MetraNet because most 
        /// objects have a prefix. For example, most columns have a "c_" prefix.
        /// </summary>
        public bool ShowActualMappings { get; set; }
        #endregion

        #region Constructor
        public UserSettings()
        {
            NewSyntax = true;
            DefaultEqualityOperator = ExpressionConstants.EqualityTechnical;
            DefaultInequalityOperator = ExpressionConstants.InequalityTechnical;
            AutoSelectInsertedSnippets = true;
            ShowActualMappings = true;
        }
        #endregion
    }
}
