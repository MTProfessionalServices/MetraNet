using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech;
using MetraTech.Interop.RCD;
using MetraTech.SecurityFramework;
using MetraTech.SecurityFramework.Serialization;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.IO;

namespace MetraTech.SecurityFrameworkUnitTests
{
    /// <summary>
    /// Provides utility methods for unit tests.
    /// </summary>
    internal static class UnitTestUtility
    {
		#region Constants

		internal const string CompressedText = "H4sIAAAAAAAEAOy9B2AcSZYlJi9tynt/SvVK1+B0oQiAYBMk2JBAEOzBiM3mkuwdaUcjKasqgcplVmVdZhZAzO2dvPfee++999577733ujudTif33/8/XGZkAWz2zkrayZ4hgKrIHz9+fB8/Ij7/qWKVzvJpNcvrdLFu2nS9nFaLVZ03TVosV+s2bfJftM6X0zydXKefv/gq/UGxStdtURbt9fj/CQAA///aod17PwAAAA==";
		internal const string DecompressedText = "GZip decoder must uncompress input sequence by GNU zip utility.";

		private const string ConfigDirectoryName = "TestConfigs";

		#endregion

		/// <summary>
        /// Loads the Security Framework configuration.
        /// </summary>
        /// <param name="testContext"></param>
        /// <param name="rootFileName">Specisies a name of the root configuration file.</param>
        /// <remarks>
        /// Call this method from initializing methods decorated with <see cref="ClassInitializeAttribute"/>.
        /// </remarks>
        internal static void InitFrameworkConfiguration(TestContext testContext, string rootFileName)
        {
		    IMTRcd rcd = new MTRcdClass();
            var path = Path.Combine(rcd.ConfigDir, @"Security\Validation\TestConfigs", rootFileName);
            SecurityKernel.Initialize(path);
            SecurityKernel.Start();
        }

		/// <summary>
		/// Returns a full path to the specified file.
		/// </summary>
		/// <param name="testContext">Current unit test context.</param>
		/// <param name="rootFileName">A file name to create a full path to.</param>
		/// <returns>A full path to the specified file.</returns>
		internal static string GetConfigPath(TestContext testContext, string rootFileName)
		{
			string assemblyDir = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);
			string sfPropsStoreLocation = Path.Combine(assemblyDir, ConfigDirectoryName, rootFileName);
			return sfPropsStoreLocation;
		}

        /// <summary>
        /// Loads the Security Framework configuration.
        /// </summary>
        /// <param name="testContext"></param>
        /// <remarks>
        /// Call this method from initializing methods decorated with <see cref="ClassInitializeAttribute"/>.
        /// </remarks>
        internal static void InitFrameworkConfiguration(TestContext testContext)
        {
            InitFrameworkConfiguration(testContext, @"MtSfConfigurationLoader.xml");
        }

        /// <summary>
        /// Cleans up the Security Framework configuration.
        /// </summary>
        /// <remarks>
        /// Call this method from finalizing methods decorated with <see cref="ClassCleanupAttribute"/>.
        /// </remarks>
        internal static void CleanupFrameworkConfiguration()
        {
            SecurityKernel.Stop();
            SecurityKernel.Shutdown();
        }
    }
}
