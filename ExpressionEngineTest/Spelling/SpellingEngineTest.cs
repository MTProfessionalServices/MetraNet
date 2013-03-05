using System.Text;
using MetraTech.ExpressionEngine.Spelling;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Collections.Generic;

namespace ExpressionEngineTest
{ 
    [TestClass()]
    public class SpellingEngineTest
    {

        [TestMethod()]
        public void SplitByCapsTest()
        {
            AssertSplit("HelloWorld", "Hello|World");
            AssertSplit("ThisIsTooLongEvenForSomeoneLikeSuperMarioWhoLikesVerboseNames", "This|Is|Too|Long|Even|For|Someone|Like|Super|Mario|Who|Likes|Verbose|Names");
            AssertSplit("DbTable", "Db|Table");
            AssertSplit("dbTable", "db|Table");
            AssertSplit("AaBbCcDdEeFfGgHh", "Aa|Bb|Cc|Dd|Ee|Ff|Gg|Hh");
            AssertSplit("AWHOLELOTOFCAPITALLETTERS", "AWHOLELOTOFCAPITALLETTERS");
            AssertSplit("CPU", "CPU");
            AssertSplit("TheCPU", "The|CPU");
            //AssertSplit("", "");
            AssertSplit("A", "A");
            AssertSplit("c", "c");
            AssertSplit("hello", "hello");
            AssertSplit("Address1", "Address1");

            AssertSplit("CPUCycles", "CPU|Cycles");


            AssertSplit("TheDBTable", "The|DB|Table");
            AssertSplit("DBTableBig", "DB|Table|Big");
            AssertSplit("DBTable", "DB|Table");
            AssertSplit("UOMs", "UOMs");


        }

        private void AssertSplit(string stringToBeSpit, string expectedResult)
        {
            //var actualResults = SpellingEngine.SplitPascalString(stringToBeSpit);
            //var sb = new StringBuilder();
            //foreach (var part in actualResults)
            //{
            //    if (sb.Length != 0)
            //        sb.Append("|");
            //    sb.Append(part);
            //}
            //var actualResult = sb.ToString();

            //var actualResults = stringToBeSpit.SplitUpperCase();
            //var actualResult = string.Join("|", actualResults);
            //Assert.AreEqual(expectedResult, actualResult);

            var actualResults = SpellingEngine.SplitPascalOrCamelString(stringToBeSpit);
            var actualResult = string.Join("|", actualResults);
            Assert.AreEqual(expectedResult, actualResult);
        }
    }
}