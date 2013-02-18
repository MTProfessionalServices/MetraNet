using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.ExpressionEngine
{
    public static class Settings
    {

        /// <summary>
        /// Indicates if the new (i.e., EVENT.Timestamp) or old (i.e, USAGE.c_Timestamp) syntax should be used. In the future
        /// this will be driven off of the MetraNet version number.
        /// </summary>
        public static bool NewSyntax = false;

        public static string DefaultEqualityOperator = Expression.EqualityOperators[0];
        public static string DefaultInequalityOperator = Expression.InequalityOperators[0];
        public static bool AutoSelectInsertedSnippets = true;
        public static bool ShowActualMappings = false; 
    }
}
