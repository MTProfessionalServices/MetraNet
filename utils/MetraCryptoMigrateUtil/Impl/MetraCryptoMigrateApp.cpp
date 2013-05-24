
#include "MetraCryptoMigrateApp.h"
#include "DataExporter.h"
#include "DataImporter.h"
#include "ServerPasswordTransformer.h"
#include "DataSignature.h"
#include "RsaKmcCertPasswordEncryptor.h"


///////////////////////////////////////////////////////////////////////////////
// PUBLIC:
///////////////////////////////////////////////////////////////////////////////

CMetraCryptoMigrateApp::CMetraCryptoMigrateApp()
:m_executeActions(true),
 m_isConfigured(false)
{
	setUnixOptions(true);
}

CMetraCryptoMigrateApp::~CMetraCryptoMigrateApp()
{
}

///////////////////////////////////////////////////////////////////////////////
// PROTECTED:
///////////////////////////////////////////////////////////////////////////////

void 
CMetraCryptoMigrateApp::initialize(Application& self)
{
	if(!m_isConfigured)
		loadConfiguration(); 

	Application::initialize(self);
	
	SQLite::Connector::registerConnector();
	ODBC::Connector::registerConnector();

	CActionHandler* pHandler = NULL;

	pHandler = new CDataExporter();
	m_actionHandlers[pHandler->Name()] = pHandler;

	pHandler = new CDataImporter();
	m_actionHandlers[pHandler->Name()] = pHandler;

	pHandler = new CServerPasswordTransformer(true);
	m_actionHandlers[pHandler->Name()] = pHandler;

	pHandler = new CServerPasswordTransformer(false);
	m_actionHandlers[pHandler->Name()] = pHandler;

	pHandler = new CDataSignature(false);
	m_actionHandlers[pHandler->Name()] = pHandler;

	pHandler = new CDataSignature(true);
	m_actionHandlers[pHandler->Name()] = pHandler;

	pHandler = new CRsaKmcCertPasswordEncryptor();
	m_actionHandlers[pHandler->Name()] = pHandler;
}

void 
CMetraCryptoMigrateApp::uninitialize()
{
	ODBC::Connector::unregisterConnector();
	SQLite::Connector::unregisterConnector();

	Application::uninitialize();
}

void 
CMetraCryptoMigrateApp::reinitialize(Application& self)
{
	Application::reinitialize(self);
}

void 
CMetraCryptoMigrateApp::defineOptions(OptionSet& options)
{
	Application::defineOptions(options);

		options.addOption(
			Option("help", "h", "display help information on command line arguments")
				.required(false)
				.repeatable(false)
				.callback(OptionCallback<CMetraCryptoMigrateApp>(this, &CMetraCryptoMigrateApp::OnHelp)));
		
		options.addOption(
			Option("debug", "d", "show debug information")
				.required(false)
				.repeatable(false)
				.callback(OptionCallback<CMetraCryptoMigrateApp>(this, &CMetraCryptoMigrateApp::OnDebug)));

		options.addOption(
			Option("actions", "a", "load actions from a file")
				.required(false)
				.repeatable(true)
				.argument("file")
				.callback(OptionCallback<CMetraCryptoMigrateApp>(this, &CMetraCryptoMigrateApp::OnActions)));

}

int 
CMetraCryptoMigrateApp::main(const vector<string>& args)
{
	if (m_executeActions)
	{
		LogStream ls(Application::logger());

		ls.information() << "Executing MetraCryptoMigrate utility v" << MCM_VERSION << endl;

		AbstractConfiguration::Keys keys;
		config().keys("actions",keys);
		for (AbstractConfiguration::Keys::const_iterator it = keys.begin(); it != keys.end(); ++it)
		{
			string actionBase = "actions.";
			actionBase.append(*it);
			AutoPtr<AbstractConfiguration> spView = config().createView(actionBase);

			AbstractConfiguration::Keys actionKeys;
			spView->keys(actionKeys);

			if(!spView->hasProperty("name"))
			{		
				ls.trace() << "Action has no name: skipping action." << endl;
				continue;
			}


			string actionName = spView->getString("name");

			bool actionIsActive = spView->getBool("active",true);
			if(!actionIsActive)
			{
				ls.trace() << "Action is not active: skipping action: " << actionName << endl;
				continue;
			}

			map<string,SharedPtr<CActionHandler> >::const_iterator actionHandlerIt =
				m_actionHandlers.find(actionName);

			if(actionHandlerIt !=  m_actionHandlers.end())
			{
				if(!actionHandlerIt->second.isNull())
				{
					CActionHandler* pHandler = const_cast<CActionHandler*>(actionHandlerIt->second.get());
					ls.trace() << "Executing action => " << pHandler->Name() << endl;
					
					pHandler->Execute(spView);

					ls.trace() << "Done executing action => " << pHandler->Name() << endl;
				}
			}
		}
	}

	return Application::EXIT_OK;
}

void
CMetraCryptoMigrateApp::OnHelp(const string& name, const string& value)
{
	m_executeActions = false;
	DisplayHelp();
	stopOptionsProcessing();
}
	
void
CMetraCryptoMigrateApp::OnDebug(const string& name, const string& value)
{
	m_executeActions = false;

	logger().information("Application properties:");
	DisplayProperties("");

	stopOptionsProcessing();
}

void
CMetraCryptoMigrateApp::OnActions(const string& name, const string& value)
{
	loadConfiguration(value);
	m_executeActions = true;
	m_isConfigured = true;
}

void
CMetraCryptoMigrateApp::DisplayHelp()
{
	HelpFormatter helpFormatter(options());
	helpFormatter.setCommand(commandName());
	helpFormatter.setUsage("OPTIONS");
	helpFormatter.setHeader("MetraTech MetraCryptoMigrate utility [Support: kquest@metratech.com]");
	helpFormatter.format(cout);

	cout << "\n\nAvailable actions:\n" << endl;

	for(map<string,SharedPtr<CActionHandler> >::const_iterator ait = m_actionHandlers.begin();
		ait != m_actionHandlers.end(); ait++)
	{
		const CActionHandler* pHandler = ait->second.get();

		if(NULL != pHandler)
		{
			cout << "\nAction name: " << pHandler->Name() << endl
				 << "Action description: \n" << pHandler->Description() << endl;
		}
	}
}

void
CMetraCryptoMigrateApp::DisplayProperties(const string& base)
{
	AbstractConfiguration::Keys keys;
	config().keys(base, keys);
	if (keys.empty())
	{
		if (config().hasProperty(base))
		{
			string msg;
			msg.append(base);
			msg.append(" = ");
			msg.append(config().getString(base));
			logger().information(msg);
			}
	}
	else
	{
		for (AbstractConfiguration::Keys::const_iterator it = keys.begin(); it != keys.end(); ++it)
		{
			string fullKey = base;
			if (!fullKey.empty()) fullKey += '.';
			fullKey.append(*it);
			DisplayProperties(fullKey);
		}
	}
}
