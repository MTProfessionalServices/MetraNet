using MetraTech.ExpressionEngine.Validations;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MetraTech.ExpressionEngine.Validations.Enumerations;

namespace ExpressionEngineTest
{
    [TestClass()]
    public class ValidationMessageTest
    {
        /// <summary>
        ///A test for ValidationMessage Constructor
        ///</summary>
        [TestMethod()]
        public void ValidationMessageConstructorTest()
        {
            var componentName = "MetraTech.Cloud.Compute";
            var severity = SeverityType.Error;
            var message = "Hello";

            //No args
            var msg = new ValidationMessage(componentName, severity, message);
            Assert.AreEqual(componentName, msg.ComponentName);
            Assert.AreEqual(severity, msg.Severity);
            Assert.AreEqual(message, msg.Message);

            //With args
            severity = SeverityType.Info;
            msg = new ValidationMessage(severity, "Hello {0}", "World");
            Assert.AreEqual(severity, msg.Severity);
            Assert.AreEqual("Hello World", msg.Message);

            //With line number
            severity = SeverityType.Warn;
            var line = 12;
            var col = 222;
            message = "Script error";
            msg = new ValidationMessage(componentName, severity, line, col, message);
            Assert.AreEqual(componentName, msg.ComponentName);
            Assert.AreEqual(severity, msg.Severity);
            Assert.AreEqual(message, msg.Message);
            Assert.AreEqual(line, msg.LineNumber);
            Assert.AreEqual(col, msg.ColumnNumber);
        }
    }
}
