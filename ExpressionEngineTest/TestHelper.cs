using MetraTech.ExpressionEngine.Validations;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace ExpressionEngineTest
{
    public static class TestHelper
    {
        public static void AssertValidation(ValidationMessageCollection messages, int expectErrors, int expectedWarnings,
                                            int expectedInfos, string assertFailMessage)
        {
            Assert.AreEqual(expectErrors, messages.ErrorCount, "Number of errors: " + assertFailMessage);
            Assert.AreEqual(expectedWarnings, messages.WarningCount, "Number of warnings: " + assertFailMessage);
            Assert.AreEqual(expectedInfos, messages.InfoCount, "Number of infos: " + assertFailMessage);
        }
    }
}
