using System;
using System.Collections.Generic;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.TestCommon
{
    /// <summary>
    /// This attribute used instead of MSTest attribute: [TestCategory(TestTypes.FunctionalTest.ToString())]
    /// Additional category may be added from TestAreas
    /// </summary>
    [AttributeUsage(AttributeTargets.Method, AllowMultiple = true)]
    public sealed class MTFunctionalTestAttribute : TestCategoryBaseAttribute
    {
        private readonly IList<string> _testCategories;

        public MTFunctionalTestAttribute()
        {
            _testCategories = new List<string> { TestTypes.FunctionalTest.ToString() };
        }

        public MTFunctionalTestAttribute(params TestAreas[] testAreas)
        {
            _testCategories = new List<string> { TestTypes.FunctionalTest.ToString() };

            foreach (var testArea in testAreas)
            {
                _testCategories.Add(testArea.ToString());
            }
        }

        public override IList<string> TestCategories
        {
            get { return _testCategories; }
        }
    }
}