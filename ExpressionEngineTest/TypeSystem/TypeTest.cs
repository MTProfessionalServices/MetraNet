using MetraTech.ExpressionEngine.TypeSystem;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using MetraTech.ExpressionEngine;

namespace ExpressionEngineTest
{
    [TestClass()]
    public class TypeTest
    {
        /// <summary>
        /// Creation tests for types without sub classes
        ///</summary>
        [TestMethod()]
        public void BasicTypeCreateTest()
        {
            var any = TypeFactory.CreateAny();
            Assert.AreEqual(BaseType.Any, any.BaseType);
            Assert.IsTrue(any.IsAny);

            var binary = TypeFactory.CreateBinary();
            Assert.AreEqual(BaseType.Binary, binary.BaseType);
            Assert.IsTrue(binary.IsBinary);

            var boolean = TypeFactory.CreateBoolean();
            Assert.AreEqual(BaseType.Boolean, boolean.BaseType);
            Assert.IsTrue(boolean.IsBoolean);

            var dt = TypeFactory.CreateDateTime();
            Assert.AreEqual(BaseType.Binary, dt.BaseType);
            Assert.IsTrue(dt.IsDateTime);

            var guid = TypeFactory.CreateGuid();
            Assert.AreEqual(BaseType.Guid, guid.BaseType);
            Assert.IsTrue(guid.IsGuid);
            
            var uniqueId = TypeFactory.CreateUniqueId();
            Assert.AreEqual(BaseType.UniqueIdentifier, uniqueId.BaseType);
            Assert.IsTrue(uniqueId.IsUniqueIdentifier);

            var unknown = TypeFactory.CreateUnkownn();
            Assert.AreEqual(BaseType.Unknown, unknown.BaseType);
            Assert.IsTrue(unknown.IsUnknown);
        }

    }
}
