using Antlr4.Runtime;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.Domain.Test.Parsers
{
    [TestClass]
    public class ExpressionLanguageTest
    {
        [TestMethod]
        public void ExpressionLanguageBasicTest()
        {
            var lex = new ExpressionLanguageLexer(new AntlrInputStream("FirstName, LastName\n" +
                                                               "Mario, DeSousa\n" +
                                                               "John, Doe\n"));
            var tokens = new CommonTokenStream(lex);
            var parser = new ExpressionLanguageParser(tokens);
            var context = parser.file();
            Assert.AreEqual(2, context._rows.Count);
        }
    }
}
