using MetraTech.ExpressionEngine.Expressions.Constants;

namespace MetraTech.ExpressionEngine
{
    /// <summary>
    /// This shouldn't be static as it will be assoicated with each user... Until we have a user context, this will do
    /// </summary>
    public class UserSettings
    {
        #region Properties
        /// <summary>
        /// Indicates if the new (i.e., EVENT.Timestamp) or old (i.e, USAGE.c_Timestamp) syntax should be used. In the future
        /// this will be driven off of the MetraNet version number.
        /// </summary>
        public bool NewSyntax { get; set; }

        public string DefaultEqualityOperator { get; set; }
        public string DefaultInequalityOperator { get; set; }
        public bool AutoSelectInsertedSnippets { get; set; }

        /// <summary>
        /// Indicates if 
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
        }
        #endregion
    }
}
