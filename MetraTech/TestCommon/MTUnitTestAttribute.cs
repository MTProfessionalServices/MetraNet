using System;
using System.Collections.Generic;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.TestCommon
{
    /// <summary>
    /// This attribute used instead of MSTest attribute:  [TestCategory(TestTypes.UnitTest.ToString())]
    /// </summary>
    [AttributeUsage(AttributeTargets.Method, AllowMultiple = true)]
    public sealed class MTUnitTestAttribute : TestCategoryBaseAttribute
    {
        private readonly IList<string> _testCategories;

        public MTUnitTestAttribute()
        {
            _testCategories = new List<string> { TestTypes.UnitTest.ToString() };
        }

        public override IList<string> TestCategories
        {
            get { return _testCategories; }
        }
    }
}
