using MetraTech.ExpressionEngine.Expressions.Constants;

namespace MetraTech.ExpressionEngine
{
    /// <summary>
    /// This shouldn't be static as it will be assoicated with each user... Until we have a user context, this will do
    /// </summary>
    public static class UserSettings
    {

        /// <summary>
        /// Indicates if the new (i.e., EVENT.Timestamp) or old (i.e, USAGE.c_Timestamp) syntax should be used. In the future
        /// this will be driven off of the MetraNet version number.
        /// </summary>
        public static bool NewSyntax = false;

        public static string DefaultEqualityOperator { get; set; }
        public static string DefaultInequalityOperator { get; set; }
        public static bool AutoSelectInsertedSnippets = true;
        public static bool ShowActualMappings = true; 

        static UserSettings()
        {
            DefaultEqualityOperator = ExpressionConstants.EqualityTechnical;
            DefaultInequalityOperator = ExpressionConstants.InequalityTechnical;
        }
    }
}
