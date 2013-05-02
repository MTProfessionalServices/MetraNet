using System;
using System.Net;
using System.Net.Http;
using System.Security.Policy;
using System.Web.Http;
using System.Web.Http.Controllers;
using System.Web.Http.Hosting;
using System.Web.Http.Routing;
using System.Linq;
using MetraTech.Agreements.Controllers;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Collections.Generic;
using Microsoft.VisualStudio.TestTools.UnitTesting.Web;
using MetraTech.Agreements.Models;
using MetraTech.DataAccess;


namespace AgreementTemplate.Test
{
    
    /// <summary>
    /// This is a test class for TemplateApiController and is intended
    /// to contain all TemplateApiController Unit Tests.
    /// These tests confirm that invoking the TemplateApiController on top of stubbed services
    /// generates the same results as invoking the stubbed services directly.
    ///</summary>
    [TestClass()]
    public class TemplateApiControllerTest
    {
        private const int MAXID = 10000;
        private readonly Random m_random = new Random();

        /// <summary>
        /// The service layer that will be invoked by the ApiController, typically a stub.
        /// </summary>
        private IAgreementTemplateServices m_svc;

        /// <summary>
        /// The ApiController to test
        /// </summary>
        private TemplateApiController m_target;


        private TestContext m_testContextInstance;

        /// <summary>
        /// Gets or sets the test context which provides
        /// information about and functionality for the current test run.
        ///</summary>
        public TestContext TestContext
        {
            get
            {
                return m_testContextInstance;
            }
            set
            {
                m_testContextInstance = value;
            }
        }


        // Does some web configuration setup to make Request.CreateResponse() happy
        // (specifically for the Post operation).
        // (Source: http://www.peterprovost.org/blog/2012/06/16/unit-testing-asp-dot-net-web-api/)
        private static void SetupControllerForPostTests(ApiController controller)
        {
            var config = new HttpConfiguration();
            var request = new HttpRequestMessage(HttpMethod.Post, "http://localhost/Agreements/api/templateapi");
            var route = config.Routes.MapHttpRoute("DefaultApi", "api/templateapi/{controller}/{id}");
            var routeData = new HttpRouteData(route, new HttpRouteValueDictionary {{"controller", "Template"}});

            controller.ControllerContext = new HttpControllerContext(config, routeData, request);
            controller.Request = request;
            controller.Request.Properties[HttpPropertyKeys.HttpConfigurationKey] = config;
        }


        /// <summary>
        /// Convert a list of AgreementTemplateViewModels into a list of AgreementTemplateModels.
        /// </summary>
        private static List<AgreementTemplateModel> ToModels(List<AgreementTemplateViewModel> vmodels)
        {
            List<AgreementTemplateModel> models = new List<AgreementTemplateModel>();
            foreach (AgreementTemplateViewModel vmodel in vmodels)
            {
                AgreementTemplateModel model = new AgreementTemplateModel();
                vmodel.SaveToModel(model);
                models.Add(model);
            }
            return models;
        }


        #region Additional test attributes
         
        // You can use the following additional attributes as you write your tests:
        
        //Use ClassInitialize to run code before running the first test in the class
        //[ClassInitialize()]
        //public static void MyClassInitialize(TestContext testContext)
        //{
        //}
        //
        //Use ClassCleanup to run code after all tests in a class have run
        //[ClassCleanup()]
        //public static void MyClassCleanup()
        //{
        //}

        // Use TestInitialize to run code before running each test
        [TestInitialize()]
        public void MyTestInitialize()
        {
            m_svc = AgreementTemplateServicesFactory.GetAgreementTemplateService(1);  // Use stubbed service layer.
            m_target = new TemplateApiController(m_svc);
        }
        
        //Use TestCleanup to run code after each test has run
        //[TestCleanup()]
        //public void MyTestCleanup()
        //{
        //}
        
        #endregion


        /// <summary>
        /// A test for getting a new agreement template.
        /// </summary>
        [TestMethod()]
        public void ApiTest_GetEmpty()
        {
            AgreementTemplateViewModel apiRetrievedModel = m_target.Get(-1);
            AgreementTemplateViewModel svcRetrievedModel = new AgreementTemplateViewModel(new AgreementTemplateModel());

            Assert.IsTrue(TestUtilities.UT_Equal(apiRetrievedModel, svcRetrievedModel));
        }


        /// <summary>
        /// A test to get a saved template.
        /// </summary>
        [TestMethod()]
        public void ApiTest_Get()
        {
            // Save a new template using stubbed services.  Then confirm that retrieving it
            // via ApiController gets the same results as retrieving it directly via stubbed services.

            AgreementTemplateModel templateToSave = new AgreementTemplateModel();
            templateToSave.CoreTemplateProperties.AgreementTemplateName = "Template" + m_random.Next(MAXID); //TODO: Modify other properties too!
            AgreementTemplateModel savedTemplate = m_svc.Save(templateToSave);

            // Set templateToSave's ID for subsequent comparisons.
            int newId = savedTemplate.AgreementTemplateId ?? MAXID;
            templateToSave.AgreementTemplateId = newId;

            AgreementTemplateViewModel apiRetrievedModel = m_target.Get(newId);
            Assert.IsTrue(TestUtilities.UT_Equal(apiRetrievedModel, new AgreementTemplateViewModel(templateToSave)));

            AgreementTemplateViewModel svcRetrievedModel = new AgreementTemplateViewModel(m_svc.GetAgreementTemplate(newId));
            Assert.IsTrue(TestUtilities.UT_Equal(apiRetrievedModel, svcRetrievedModel));
        }


        /// <summary>
        /// A test to get a nonexistent template.
        /// </summary>
        [TestMethod()]
        [ExpectedException(typeof(HttpResponseException))]
        public void ApiTest_GetBadId()
        {
            // Confirm that the ApiController returns HttpResponseException when asked to retrieve a nonexistent template.
            int badId = MAXID;
            AgreementTemplateViewModel apiRetrievedModel = m_target.Get(badId);
        }


        /// <summary>
        /// A test for Post.
        /// </summary>
        [TestMethod()]
        public void ApiTest_Post()
        {
            SetupControllerForPostTests(m_target);

            // Post a new template using ApiController, and in the HTTP response, check the status code
            // and extract the ID that was assigned to the template.  Retrieve the template using stubbed services.
            // Then save another new template directly via stubbed services and retrieve it again using stubbed services.
            // Confirm that the retrieved models are identical, except for the templates' IDs and names.

            AgreementTemplateModel newTemplateToPost =new AgreementTemplateModel();
            newTemplateToPost.CoreTemplateProperties.AgreementTemplateName = "Template" + m_random.Next(MAXID); //TODO: Modify other properties too!
            HttpResponseMessage resp = m_target.Post(new AgreementTemplateViewModel(newTemplateToPost));
            Assert.AreEqual(resp.StatusCode, HttpStatusCode.Created);

            // Get the new template's ID from body of httpResponse and update newTemplateToPost for subsequent comparisons.
            var myobject = resp.Content.ReadAsAsync<AgreementTemplateViewModel>();
            int newPostedId = myobject.Result.AgreementTemplateId ?? MAXID;
            newTemplateToPost.AgreementTemplateId = newPostedId;

            AgreementTemplateViewModel apiSavedModel = new AgreementTemplateViewModel(m_svc.GetAgreementTemplate(newPostedId));
            Assert.IsTrue(TestUtilities.UT_Equal(apiSavedModel, new AgreementTemplateViewModel(newTemplateToPost)));

            // Now save a new template and retrieve it using stubbed services.
            AgreementTemplateModel newTemplateToSave = new AgreementTemplateModel();
            newTemplateToSave.CoreTemplateProperties.AgreementTemplateName = "Template" + m_random.Next(MAXID); //TODO: Modify other properties too!
            AgreementTemplateModel savedTemplate = m_svc.Save(newTemplateToSave);
            int newSavedId = savedTemplate.AgreementTemplateId ?? MAXID;
            AgreementTemplateViewModel svcSavedModel = new AgreementTemplateViewModel(m_svc.GetAgreementTemplate(newSavedId));

            // Change the template's ID and name before comparing with apiSavedModel.
            svcSavedModel.AgreementTemplateId = apiSavedModel.AgreementTemplateId;
            svcSavedModel.CoreTemplateProperties.AgreementTemplateName =
                apiSavedModel.CoreTemplateProperties.AgreementTemplateName;

            Assert.IsTrue(TestUtilities.UT_Equal(apiSavedModel, svcSavedModel));
        }


        /// <summary>
        /// A test to post a new template with a name that's already in use by another template.
        /// </summary>
        [TestMethod()]
        [ExpectedException(typeof(HttpResponseException))]
        public void ApiTest_PostDuplicateName()
        {
            SetupControllerForPostTests(m_target);

            // Confirm that the ApiController returns HttpResponseException when it tries to post
            // a new template with a name that's already in use.

            string uniqueName = "UniqueTemplateName" + m_random.Next(MAXID);
            HttpResponseMessage resp;

            AgreementTemplateModel templateOne = new AgreementTemplateModel();
            templateOne.CoreTemplateProperties.AgreementTemplateName = uniqueName;
            resp = m_target.Post(new AgreementTemplateViewModel(templateOne));
            Assert.AreEqual(resp.StatusCode, HttpStatusCode.Created);

            AgreementTemplateModel templateTwo = new AgreementTemplateModel();
            templateTwo.CoreTemplateProperties.AgreementTemplateName = uniqueName;
            resp = m_target.Post(new AgreementTemplateViewModel(templateTwo));
        }


        /// <summary>
        /// A test for Put.
        /// </summary>
        [TestMethod()]
        public void ApiTest_Put()
        {
            // Using stubbed services, save a template and then retrieve it.
            // Modify the template and save it via an ApiController Put; then retrieve it using stubbed services.
            // Then save the template directly via stubbed services and retrieve it again using stubbed services.
            // Confirm that the retrieved models are identical.

            AgreementTemplateModel templateToSave = new AgreementTemplateModel();
            templateToSave.CoreTemplateProperties.AgreementTemplateName = "Template" + m_random.Next(MAXID);
            templateToSave.CoreTemplateProperties.AgreementTemplateDescription = "Original template description"; //TODO: Modify other properties too!
            AgreementTemplateModel savedTemplate = m_svc.Save(templateToSave);

            // Get the ID that was assigned to the new template.
            int newId = savedTemplate.AgreementTemplateId ?? MAXID;

            AgreementTemplateModel templateToModify = m_svc.GetAgreementTemplate(newId);
            string updatedDesc = "Modified template description";
            templateToModify.CoreTemplateProperties.AgreementTemplateDescription = updatedDesc;

            AgreementTemplateViewModel putReturnedModel = m_target.Put(newId, new AgreementTemplateViewModel(templateToModify));
            Assert.IsTrue(TestUtilities.UT_Equal(putReturnedModel, new AgreementTemplateViewModel(templateToModify)));
            Assert.AreEqual(putReturnedModel.CoreTemplateProperties.AgreementTemplateDescription, updatedDesc);

            AgreementTemplateViewModel apiSavedModel = new AgreementTemplateViewModel(m_svc.GetAgreementTemplate(newId));
            Assert.IsTrue(TestUtilities.UT_Equal(apiSavedModel, putReturnedModel));

            m_svc.Save(templateToModify);
            AgreementTemplateViewModel svcSavedModel = new AgreementTemplateViewModel(m_svc.GetAgreementTemplate(newId));

            Assert.IsTrue(TestUtilities.UT_Equal(apiSavedModel, svcSavedModel));
        }


        /// <summary>
        /// A test for Put.  If the put ID doesn't match the template ID, throw an exception.
        /// </summary>
        [TestMethod()]
        [ExpectedException(typeof(HttpResponseException))]
        public void ApiTest_PutNonMatchingId()
        {
            SetupControllerForPostTests(m_target);
            // Using stubbed services, save a template and then retrieve it.
            // Now save it again, but with the wrong ID.

            AgreementTemplateModel templateToSave = new AgreementTemplateModel();
            templateToSave.CoreTemplateProperties.AgreementTemplateName = "Template" + m_random.Next(MAXID);
            templateToSave.CoreTemplateProperties.AgreementTemplateDescription = "Original template description"; //TODO: Modify other properties too!
            AgreementTemplateModel savedTemplate = m_svc.Save(templateToSave);

            // Get the ID that was assigned to the new template.
            int newId = savedTemplate.AgreementTemplateId ?? MAXID;

            AgreementTemplateModel templateToModify = m_svc.GetAgreementTemplate(newId);
            string updatedDesc = "Modified template description";
            templateToModify.CoreTemplateProperties.AgreementTemplateDescription = updatedDesc;

            m_target.Put(newId + 1, new AgreementTemplateViewModel(templateToModify));
           }

        /// <summary>
        /// A test for GetAllAgreementTemplates.  This test does not exercise filtering/sorting/paging
        /// functionality; that is tested in AgreementTemplateServicesTest.
        /// </summary>
        [TestMethod()]
        public void ApiTest_GetAllAgreementTemplates()
        {
            // Retrieve all agreements using the ApiController and then the stubbed service directly
            // and confirm that the results are the same.

            // Save some agreement templates to be retrieved later.
            AgreementTemplateModel templateToSave;
            templateToSave = new AgreementTemplateModel();
            templateToSave.CoreTemplateProperties.AgreementTemplateName = "Template" + m_random.Next(MAXID);
            m_svc.Save(templateToSave);
            templateToSave = new AgreementTemplateModel();
            templateToSave.CoreTemplateProperties.AgreementTemplateName = "Template" + m_random.Next(MAXID);
            m_svc.Save(templateToSave);
            templateToSave = new AgreementTemplateModel();
            templateToSave.CoreTemplateProperties.AgreementTemplateName = "Template" + m_random.Next(MAXID);
            m_svc.Save(templateToSave);

            // Since the stubbed service doesn't support filtering/sorting/paging, we will leave it to
            // AgreementTemplateServicesTest.cs to test filtering/sorting/paging.  
            // Here, we will use the default search parameters, so GetAllAgreementTemplates()
            // will return a page of at most 10 templates.
            TemplatesResultsPage apiResult = m_target.GetAllAgreementTemplates();
            List<AgreementTemplateModel> apiTemplateList = ToModels(apiResult.templateViewModels);

            List<FilterElement> filters = new List<FilterElement>();
            List<SortCriteria> sorters = new List<SortCriteria>(); ;
            int pagesize = 10;  // Beware the effect of page size.
            int pagecount = 1;
            List<AgreementTemplateModel> svcTemplateList;
            m_svc.GetAgreementTemplates(filters, sorters, pagesize, pagecount, out svcTemplateList);

            TestContext.WriteLine("apiTemplateList.Count={0}", apiTemplateList.Count);
            TestContext.WriteLine("svcTemplateList.Count={0}", svcTemplateList.Count);
            Assert.AreEqual(apiResult.totalCountAcrossPages, svcTemplateList.Count); // Requires that count < pageSize (10)
            Assert.IsTrue(TestUtilities.UT_ListEqual(apiTemplateList, svcTemplateList),
                          "ApiController didn't return expected set of templates.");
        }


        /// <summary>
        /// A test to parse filter values from a formatted string.
        /// </summary>
        [TestMethod()]
        public void ApiTest_ParseFilterValues()
        {
            string testFilterString = "strPropName1::Like::%value1%;;propName2::IsNull;;;;numPropName3::NotEqual::123";

            List<FilterElement> expectedFilters = new List<FilterElement>();
            FilterElement expectedFilter;
            expectedFilter = new FilterElement("strPropName1", FilterElement.OperationType.Like, "%value1%");
            expectedFilters.Add(expectedFilter);
            expectedFilter = new FilterElement("propName2", FilterElement.OperationType.IsNull, null);
            expectedFilters.Add(expectedFilter);
            expectedFilter = new FilterElement("numPropName3", FilterElement.OperationType.NotEqual, "123");
            expectedFilters.Add(expectedFilter);

            List<FilterElement> actualFilters = m_target.ParseFilterValues(testFilterString);

            Assert.IsTrue(TestUtilities.UT_ListEqual(expectedFilters, actualFilters),
                          String.Format("Mismatch between {0} expected filter values and {1} actual filter values",
                                        expectedFilters.Count, actualFilters.Count));
        }


        /// <summary>
        /// A test to parse filter values from a formatted string, using non-default delimiters.
        /// </summary>
        [TestMethod()]
        public void ApiTest_ParseFilterValuesDiffDelims()
        {
            string testFilterString = "strPropName1-Like-%value1%|propName2-IsNull||numPropName3-NotEqual-123";

            List<FilterElement> expectedFilters = new List<FilterElement>();
            FilterElement expectedFilter;
            expectedFilter = new FilterElement("strPropName1", FilterElement.OperationType.Like, "%value1%");
            expectedFilters.Add(expectedFilter);
            expectedFilter = new FilterElement("propName2", FilterElement.OperationType.IsNull, null);
            expectedFilters.Add(expectedFilter);
            expectedFilter = new FilterElement("numPropName3", FilterElement.OperationType.NotEqual, "123");
            expectedFilters.Add(expectedFilter);

            List<FilterElement> actualFilters = m_target.ParseFilterValues(testFilterString, "|", "-");

            Assert.IsTrue(TestUtilities.UT_ListEqual(expectedFilters, actualFilters),
                          String.Format("Mismatch between {0} expected filter values and {1} actual filter values",
                                        expectedFilters.Count, actualFilters.Count));
        }


        /// <summary>
        /// A test to parse badly formatted filter values.
        /// </summary>
        [TestMethod()]
        [ExpectedException(typeof(FormatException))]
        public void ApiTest_ParseBadFilterValue1()
        {
            string testFilterString = "propWithBadOpName::like::%value1%";
            m_target.ParseFilterValues(testFilterString);
        }


        /// <summary>
        /// A test to parse badly formatted filter values.
        /// </summary>
        [TestMethod()]
        [ExpectedException(typeof(FormatException))]
        public void ApiTest_ParseBadFilterValue2()
        {
            string testFilterString = "propWithUnnecValue::IsNull::badVal";
            m_target.ParseFilterValues(testFilterString);
        }


        /// <summary>
        /// A test to parse badly formatted filter values.
        /// </summary>
        [TestMethod()]
        [ExpectedException(typeof(FormatException))]
        public void ApiTest_ParseBadFilterValue3()
        {
            string testFilterString = "propWithNoOp;;";
            m_target.ParseFilterValues(testFilterString);
        }


        /// <summary>
        /// A test to parse badly formatted filter values.
        /// </summary>
        [TestMethod()]
        [ExpectedException(typeof(FormatException))]
        public void ApiTest_ParseBadFilterValue4()
        {
            string testFilterString = "propWithEmptyField::Equal::";
            m_target.ParseFilterValues(testFilterString);
        }


        /// <summary>
        /// A test to parse sort criteria from a formatted string.
        /// </summary>
        [TestMethod()]
        public void ApiTest_ParseSortValues()
        {
            string testSortString = "-propName1;;propName2;;;;+propName3;;";

            List<SortCriteria> expectedSorters = new List<SortCriteria>();
            SortCriteria expSorter;
            expSorter = new SortCriteria("propName1", SortDirection.Descending);
            expectedSorters.Add(expSorter);
            expSorter = new SortCriteria("propName2", SortDirection.Ascending);
            expectedSorters.Add(expSorter);
            expSorter = new SortCriteria("propName3", SortDirection.Ascending);
            expectedSorters.Add(expSorter);

            List<SortCriteria> actualSorters = m_target.ParseSortValues(testSortString);

            Assert.IsTrue(TestUtilities.UT_ListEqual(expectedSorters, actualSorters),
                          String.Format("Mismatch between {0} expected sort criteria and {1} actual sort criteria",
                                        expectedSorters.Count, actualSorters.Count));
        }


        /// <summary>
        /// A test to parse sort criteria from a formatted string, using a non-default delimiter string.
        /// </summary>
        [TestMethod()]
        public void ApiTest_ParseSortValuesDiffDelim()
        {
            string testSortString = "-propName1|propName2||+propName3|";

            List<SortCriteria> expectedSorters = new List<SortCriteria>();
            SortCriteria expSorter;
            expSorter = new SortCriteria("propName1", SortDirection.Descending);
            expectedSorters.Add(expSorter);
            expSorter = new SortCriteria("propName2", SortDirection.Ascending);
            expectedSorters.Add(expSorter);
            expSorter = new SortCriteria("propName3", SortDirection.Ascending);
            expectedSorters.Add(expSorter);

            List<SortCriteria> actualSorters = m_target.ParseSortValues(testSortString, "|");

            Assert.IsTrue(TestUtilities.UT_ListEqual(expectedSorters, actualSorters),
                          String.Format("Mismatch between {0} expected sort criteria and {1} actual sort criteria",
                                        expectedSorters.Count, actualSorters.Count));
        }


        /// <summary>
        /// A test to parse badly formatted sort criteria.
        /// </summary>
        [TestMethod()]
        [ExpectedException(typeof(FormatException))]
        public void ApiTest_ParseBadSortValue()
        {
            string testSortString = "-propName1;;+;;propName3;;";
            m_target.ParseSortValues(testSortString);
        }


        // TODO:  Tests to add:
        // - Post(InvalidViewModel)
        // - Put(InvalidViewModel)

    }
}
