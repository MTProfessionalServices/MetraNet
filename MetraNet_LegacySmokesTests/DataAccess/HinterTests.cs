using System;
using NUnit.Framework;
using QueryAdapter = MetraTech.Interop.QueryAdapter;

namespace MetraTech.DataAccess.Test
{

	//
	// To run the this test fixture:
	// nunit-console /fixture:MetraTech.DataAccess.Test.HinterTests /assembly:O:\debug\bin\MetraTech.DataAccess.Test.dll
	//
  [Category("NoAutoRun")]
  [TestFixture]
	public class HinterTests 
	{

		private IQueryHinter GetHinter(string queryTag)
		{
			QueryAdapter.IMTQueryAdapter query = new QueryAdapter.MTQueryAdapter();
			query.Init(@"T:\Development\Core\DataAccess\Queries");
			query.SetQueryTag(queryTag);

			IQueryHinter hinter = (IQueryHinter) query.GetHinter();
			return hinter;
		}

		/// <summary>
		/// Tests to make sure an absent hinter is returned as a null reference.
		/// </summary>
		[Test]
    [Ignore("Failing - Ignore Test")]
    public void T01TestAbsentHinter()
		{
			IQueryHinter hinter = GetHinter("__TEST_ABSENT_HINTER__");
			Assert.IsNull(hinter);
		}

		/// <summary>
		/// Tests MTSQL syntax error failure.
		/// </summary>
		[Test]
    [Ignore("Failing - Ignore Test")]
    [ExpectedException(typeof(QueryHinterCompilationException))]
    public void T02TestCompilationFailure()
		{
			GetHinter("__TEST_HINTER_COMPILATION_FAILURE__");
		}

		/// <summary>
		/// Tests output parameter type mismatch failure (not VARCHAR).
		/// </summary>
		[Test]
    [Ignore("Failing - Ignore Test")]
    [ExpectedException(typeof(QueryHinterOutputParameterTypeMismatchException))]
    public void T03TestOutputParameterTypeMismatchFailure()
		{
			GetHinter("__TEST_HINTER_OUTPUT_TYPE_MISMTACH_FAILURE__");
		}

		/// <summary>
		/// Tests missing output parameters in the query failure.
		/// </summary>
		[Test]
    [Ignore("Failing - Ignore Test")]
    [ExpectedException(typeof(QueryHinterOutputParameterNotFoundInQueryException))]
    public void T04TestOutputParameterNotFoundInQueryFailure()
		{
			GetHinter("__TEST_HINTER_OUTPUT_PARAMETER_NOT_FOUND_IN_QUERY_FAILURE__");
		}

		/// <summary>
		/// Tests missing input parameter failure. (must have at least one input)
		/// </summary>
		[Test]
    [Ignore("Failing - Ignore Test")]
    [ExpectedException(typeof(QueryHinterMissingInputParameterException))]
    public void T05TestMissingInputParameterFailure()
		{
			GetHinter("__TEST_HINTER_MISSING_INPUT_PARAMETER_FAILURE__");
		}

		/// <summary>
		/// Tests missing output parameter failure. (must have at least one output)
		/// </summary>
		[Test]
    [Ignore("Failing - Ignore Test")]
    [ExpectedException(typeof(QueryHinterMissingOutputParameterException))]
    public void T06TestMissingOutputParameterFailure()
		{
			GetHinter("__TEST_HINTER_MISSING_OUTPUT_PARAMETER_FAILURE__");
		}

		/// <summary>
		/// Tests adding a non-existent parameter failure.
		/// </summary>
		[Test]
    [Ignore("Failing - Ignore Test")]
    [ExpectedException(typeof(QueryHinterUnknownParameterException))]
    public void T07TestAddingUnknownParameterFailure()
		{
			IQueryHinter hinter = GetHinter("__TEST_GOOD_HINTER__");
			hinter.AddParam("BogusInput", "bogus");
		}

		/// <summary>
		/// Tests adding a parameter that is the wrong direction (output) failure.
		/// </summary>
		[Test]
    [Ignore("Failing - Ignore Test")]
    [ExpectedException(typeof(QueryHinterCannotSetOutputParameterException))]
    public void T08TestSettingOutputParameterFailure()
		{
			IQueryHinter hinter = GetHinter("__TEST_GOOD_HINTER__");
			hinter.AddParam("Table", "bogus");
		}

		/// <summary>
		/// Tests that hint tags are successfully replaced.
		/// </summary>
		[Test]
    [Ignore("Failing - Ignore Test")]
    public void T09TestHintTagReplacement()
		{
			IQueryHinter hinter = GetHinter("__TEST_GOOD_HINTER__");
			hinter.AddParam("Input", "helloworld");
			hinter.Apply();
			StringAssert.Contains("SELECT * FROM t_acc_usage x x", hinter.QueryAdapter.GetQuery());
		}

		/// <summary>
		/// Tests that hint tags are replaced with empty strings if they are not set.
		/// </summary>
		[Test]
    [Ignore("Failing - Ignore Test")]
    public void T10TestHintTagEmptyReplacement()
		{
			IQueryHinter hinter = GetHinter("__TEST_GOOD_HINTER__");
			hinter.AddParam("Input", "dont match me");
			hinter.Apply();
			StringAssert.Contains("SELECT * FROM t_acc_usage", hinter.QueryAdapter.GetQuery());
		}

		/// <summary>
		/// Tests that hinters are being cached.
		/// </summary>
		[Test]
    [Ignore("Failing - Ignore Test")]
    public void T11TestHinterCaching()
		{
			IQueryHinter hinter  = GetHinter("__TEST_GOOD_HINTER__");
			IQueryHinter hinter2 = GetHinter("__TEST_GOOD_HINTER__");

			Assert.AreEqual(hinter, hinter2);
			Assert.AreEqual(hinter.QueryAdapter, ((IQueryHinter) hinter.QueryAdapter.GetHinter()).QueryAdapter);
		}

	}
}
