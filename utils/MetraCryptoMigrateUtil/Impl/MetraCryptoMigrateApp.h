#ifndef _INCLUDE_METRA_CRYPTO_MIGRATE_APP_H_
#define _INCLUDE_METRA_CRYPTO_MIGRATE_APP_H_

#include "AppIncludes.h"
#include "ActionHandler.h"

#define MCM_VERSION 16

class CMetraCryptoMigrateApp: public Application
{
public:
	CMetraCryptoMigrateApp();
	~CMetraCryptoMigrateApp();

protected:	
	virtual void initialize(Application& self);
	virtual void uninitialize();
	virtual void reinitialize(Application& self);
	virtual void defineOptions(OptionSet& options);
	virtual int main(const vector<string>& args);

	void OnHelp(const string& name, const string& value);
	void OnDebug(const string& name, const string& value);
	void OnActions(const string& name, const string& value);
		
	void DisplayHelp();
	void DisplayProperties(const string& base);
	
private:
	bool m_executeActions;
	bool m_isConfigured;
	map<string,SharedPtr<CActionHandler> > m_actionHandlers;
};


#endif
