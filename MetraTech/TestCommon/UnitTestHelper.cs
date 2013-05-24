using System.Data.SqlClient;
using System.Runtime.Serialization;

namespace MetraTech.TestCommon
{
    /// <summary>
    /// UnitTestHelper contains common staff for unit testing
    /// </summary>
    public static class UnitTestHelper
    {
        /// <summary>
        /// Provides an ability for creation new instance of SqlException, that has no public constructor.
        /// Required for emulation SqlException in unit tests.
        /// </summary>
        /// <returns>New instance of SqlException</returns>
        public static SqlException GetSqlException()
        {
            return Instantiate<SqlException>();
        }

        private static T Instantiate<T>() where T : class
        {
            return FormatterServices.GetUninitializedObject(typeof(T)) as T;
        }
    }
}