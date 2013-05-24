
#include "ServerPasswordTransformer.h"


static string gServersFileName = "servers.xml";
static string gProtectedPropertyList = "serveraccess\\protectedpropertylist.xml";
static string gSignIoLogin = "paymentsvr\\config\\paymentserver\\signiologin.xml";


CServerPasswordTransformer::CServerPasswordTransformer(bool isExporter)
:m_isExporter(isExporter),
 m_doServersFiles(true),
 m_doProtectedPropertyListFile(true),
 m_doSignIoLoginFile(true),
 m_doMirrorData(true),
 m_doUpdateSource(false),
 m_fromMirror(false),
 m_transformCount(0)
{
	m_rsaPiNumberKeyClass = "CreditCardNumber";
	m_rsaPiHashKeyClass = "PaymentInstHash";
	m_rsaPassKeyClass = "PasswordHash";

	if(m_isExporter)
	{
		m_name = "ExportPasswords";
		m_description = "Converts server passwords from the machine specific format into its export format";
	}
	else
	{
		m_name = "ImportPasswords";
		m_description = "Converts server passwords from the export format back into its machine specific format";
	}
}

CServerPasswordTransformer::~CServerPasswordTransformer()
{
}

void 
CServerPasswordTransformer::ClearParams()
{
	m_transformCount = 0;
	m_doServersFiles = true;
	m_doProtectedPropertyListFile = true;
	m_doSignIoLoginFile = true;
	m_doMirrorData = true;
	m_doUpdateSource = false;
	m_fromMirror = false;
	m_configDir.clear();
	m_extensionDir.clear();

	m_tid.clear();
	m_dttPassPhrase.clear();
	m_rsaKmcConfigFileName.clear();
	m_rsaKmcCertPass.clear();
	m_rsaPiNumberKeyClass = "CreditCardNumber";
	m_rsaPiHashKeyClass = "PaymentInstHash";
	m_rsaPassKeyClass = "PasswordHash";
}

bool 
CServerPasswordTransformer::GetParams(AutoPtr<AbstractConfiguration> spParams)
{
	bool isOk = false;
	try
	{
		if(!spParams->hasProperty("params.tid"))
			throw Exception("Missing parameter");

		m_tid = spParams->getString("params.tid");

		if(!spParams->hasProperty("params.dttPassPhrase"))
			throw Exception("Missing parameter");

		m_dttPassPhrase = spParams->getString("params.dttPassPhrase");
		if(m_dttPassPhrase.length() < 12)
			throw Exception("DTT passphrase must be at least 12 characters");

		if(!spParams->hasProperty("params.rsaKmcConfigFileName"))
			throw Exception("Missing parameter");

		m_rsaKmcConfigFileName = spParams->getString("params.rsaKmcConfigFileName");

		if(!spParams->hasProperty("params.rsaKmcCertPass"))
			throw Exception("Missing parameter");

		m_rsaKmcCertPass = spParams->getString("params.rsaKmcCertPass");

		m_rsaPiNumberKeyClass = spParams->getString("params.rsaPiNumberKeyClass","CreditCardNumber");
		m_rsaPiHashKeyClass = spParams->getString("params.rsaPiHashKeyClass","PaymentInstHash");
		m_rsaPassKeyClass = spParams->getString("params.rsaPassKeyClass","PasswordHash");

		if(!spParams->hasProperty("params.configDir"))
			throw Exception("Missing parameter");

		m_configDir = spParams->getString("params.configDir");

		if(!spParams->hasProperty("params.extensionDir"))
			throw Exception("Missing parameter");

		m_extensionDir = spParams->getString("params.extensionDir");

		m_doMirrorData = spParams->getBool("params.mirror",false);
		m_doUpdateSource = spParams->getBool("params.serversFiles",true);
		m_doUpdateSource = spParams->getBool("params.protectedpropertylistFile",true);
		m_doUpdateSource = spParams->getBool("params.signiologinFile",true);

		if(m_isExporter)
		{
			m_doUpdateSource = spParams->getBool("params.updateSource",true);
		}
		else
		{
			m_doUpdateSource = spParams->getBool("params.updateTarget",true);
			m_fromMirror = spParams->getBool("params.fromMirror",true);
		}

		isOk = true;
	}
	catch(Exception& x)
	{
		m_logger.error() << __FUNCTION__ << " : " << x.displayText() << endl;
	}
	return isOk;
}

bool
CServerPasswordTransformer::Execute(AutoPtr<AbstractConfiguration> spParams)
{
	bool isOk = false;

	if(spParams.isNull())
		return isOk;

	try
	{
		ClearParams();
		if(!GetParams(spParams))
			throw Exception("Bad parameters");

		m_spDttRecord = new CDataTransformTransaction(m_tid + ".spt");

		if(!m_spDttRecord->SetPassPhrase(m_dttPassPhrase))
			throw Exception("Could setup DTT");

		m_spCryptoEngine = new CCryptoEngine();

		if(m_isExporter)
		{
			m_spCryptoEngine->GenerateKey();

			string kv;
			string kiv;

			if(!m_spCryptoEngine->GetKeyAsHexString(kv,kiv))
				throw Exception("CE error");

			m_spDttRecord->SetDataKey(m_tid,kv,kiv);
			kv.clear();
			kiv.clear();

			m_spDttRecord->SetTransformedSource(m_doUpdateSource);
			m_spDttRecord->SetDataMirror(m_doMirrorData);
		}
		else
		{
			if(!m_spDttRecord->Restore())
				throw Exception("Could not restore DTT");

			string kid;
			string kv;
			string kiv;
			if(!m_spDttRecord->GetDataKey(kid,kv,kiv) || ((kid != m_tid) || kid.empty() || kv.empty() || kiv.empty()))
				throw Exception("DTT data error");
		

			if(!m_spCryptoEngine->SetKeyAsHexString(kv,kiv))
				throw Exception("CE error");

			kid.clear();
			kv.clear();
			kiv.clear();
		}

		m_spRsaKmClient = new CRsaKeyManagerClient(m_rsaKmcConfigFileName,m_rsaKmcCertPass,
											m_rsaPiNumberKeyClass,m_rsaPiHashKeyClass,m_rsaPassKeyClass);

		if(m_doServersFiles)
		{
			vector<string> serversFiles;

			string fileToFind = gServersFileName;

			if(m_fromMirror && !m_isExporter)
			{
				fileToFind.append(".exported.xml");
			}

			if(!FindFiles(m_configDir,fileToFind,serversFiles))
				throw Exception("Error finding server files");

			if(!FindFiles(m_extensionDir,fileToFind,serversFiles))
				throw Exception("Error finding server files");

			size_t max = serversFiles.size();
			for(size_t i = 0;i < max;i++)
			{
				if(!ProcessFile(serversFiles[i],"password"))
					m_logger.warning() << __FUNCTION__ << " : Error transforming " << serversFiles[i] << endl;
			}
		}

		if(m_doProtectedPropertyListFile)
		{
			string fullFileName;
			if(!m_configDir.empty())
			{
				fullFileName.append(m_configDir);
				fullFileName += Path::separator();
			}
			fullFileName.append(gProtectedPropertyList);

			if(m_fromMirror && !m_isExporter)
			{
				fullFileName.append(".exported.xml");
			}

			File f(fullFileName);
			if (f.exists())
			{
				if(!ProcessFile(fullFileName,"value"))
					m_logger.warning() << __FUNCTION__ << " : Error transforming protectedpropertylist.xml" << endl;
			}
		}

		if(m_doSignIoLoginFile)
		{
			string fullFileName;
			if(!m_extensionDir.empty())
			{
				fullFileName.append(m_extensionDir);
				fullFileName += Path::separator();
			}
			fullFileName.append(gSignIoLogin);

			if(m_fromMirror && !m_isExporter)
			{
				fullFileName.append(".exported.xml");
			}

			File f(fullFileName);
			if (f.exists())
			{
				if(!ProcessFile(fullFileName,"value"))
					m_logger.warning() << __FUNCTION__ << " : Error transforming signiologin.xml" << endl;
			}
		}

		m_spDttRecord->SetDataCount(m_transformCount);

		if(!m_spDttRecord->Save())
		{
			m_logger.warning() << __FUNCTION__ << " : Could not save DTT" << endl;
		}
	}
	catch(Exception& x)
	{
		m_logger.error() << __FUNCTION__ << " : " << x.displayText() << endl;
	}

	m_spRsaKmClient = NULL;
	m_spCryptoEngine = NULL;
	m_spDttRecord = NULL;
	ClearParams();

	return isOk;
}

bool
CServerPasswordTransformer::FindFiles(const string& path,const string& name,vector<string>& files)
{
	bool isOk = false;

	File f(path);
	if(!f.exists())
		return true;

	if(!f.isDirectory())
		return false;

	bool findAll = false;
	if(name.empty())
	{
		findAll = true;
	}

	try
	{
		vector<string> paths;
		if(path.empty())
			paths.push_back(Path::current());
		else
			paths.push_back(path);

		while(1)
		{
			if(paths.empty())
			{
				break;
			}

			string dirName = paths.back();
			paths.pop_back();
			DirectoryIterator dit(dirName);
			DirectoryIterator end;

			while(dit != end)
			{
				Path p(dit->path());
				string pname = p.getFileName();

				if(dit->isDirectory())
				{
					paths.push_back(p.toString());
				}
				else
				{
					if(findAll)
						files.push_back(p.toString());
					else if(pname == name)
						files.push_back(p.toString());
				}

				++dit;
			}
		}

		isOk = true;
	}
	catch(Exception& x)
	{
		m_logger.error() << __FUNCTION__ << " : " <<  x.displayText() << endl;
	}

	return isOk;
}

bool
CServerPasswordTransformer::ProcessFile(const string& fileName,const string& tagName)
{
	bool isOk = false;

	File f(fileName);
	if (!f.exists() || tagName.empty())
		return isOk;

	FileInputStream fis(fileName);
	if(!fis.good())
		return isOk;

	InputSource src(fis);
	
	try
	{
		DOMParser parser;
		AutoPtr<Document> apDoc = parser.parse(&src);

		bool changedFields = false;
		NodeList* myNodes = apDoc->getElementsByTagName(tagName);
		if(NULL != myNodes)
		{
			unsigned long max = myNodes->length();
			for(unsigned long i = 0;i < max;i++)
			{
				Node* pNode = myNodes->item(i);
				unsigned short ntype = pNode->nodeType();

				if(Node::ELEMENT_NODE == ntype)
				{
					Element* pElem = dynamic_cast<Element*>(pNode);
					if(NULL != pElem)
					{

						if(!pElem->hasAttribute("encrypted") && (pElem->getAttribute("encrypted") != "true"))
							continue;

						if(m_isExporter)
						{
							if(pElem->hasAttribute("exported") && (pElem->getAttribute("exported") == "true"))
								continue;

							string nodeValue = pElem->innerText();
							if(nodeValue.empty())
								continue;

							string decNodeValue;
							if(m_spRsaKmClient->DecryptCcNumber(nodeValue,decNodeValue))
							{
								string recryptedNodeValue;
								if(m_spCryptoEngine->Encrypt(decNodeValue,recryptedNodeValue,true))
								{
									AutoPtr<Text> apText = apDoc->createTextNode(recryptedNodeValue);

									NodeList* pElemNodes = pElem->childNodes();
									if(NULL != pElemNodes)
									{
										unsigned long emax = pElemNodes->length();
										for(unsigned long j = 0;j < emax;j++)
										{
											Node* pChildNode = pElemNodes->item(j);
											pElem->removeChild(pChildNode);
										}
									}
									pElem->appendChild(apText);

									pElem->setAttribute("exported","true");
									changedFields = true;
									m_transformCount++;
								}
								else
								{
									m_logger.warning() << __FUNCTION__ << " : Could not process field" << endl;
								}
							}
							else
							{
								m_logger.warning() << __FUNCTION__ << " : Could not process field" << endl;
							}
						}
						else
						{
							if(pElem->hasAttribute("exported") && (pElem->getAttribute("exported") == "true"))
							{
								string nodeValue = pElem->innerText();
								if(nodeValue.empty())
									continue;

								string decNodeValue;
								if(m_spCryptoEngine->Decrypt(nodeValue,decNodeValue,true))
								{
									string recryptedNodeValue;
									if(m_spRsaKmClient->EncryptCcNumber(decNodeValue,recryptedNodeValue))
									{
										AutoPtr<Text> apText = apDoc->createTextNode(recryptedNodeValue);

										NodeList* pElemNodes = pElem->childNodes();
										if(NULL != pElemNodes)
										{
											unsigned long emax = pElemNodes->length();
											for(unsigned long j = 0;j < emax;j++)
											{
												Node* pChildNode = pElemNodes->item(j);
												pElem->removeChild(pChildNode);
											}
										}
										pElem->appendChild(apText);

										pElem->setAttribute("exported","false");
										pElem->removeAttribute("exported");
										changedFields = true;
										m_transformCount++;
									}
									else
									{
										m_logger.warning() << __FUNCTION__ << " : Could not process field" << endl;
									}
								}
								else
								{
									m_logger.warning() << __FUNCTION__ << " : Could not process field" << endl;
								}
							}
						}

					}
				}
			}
		}

		if(changedFields)
		{
			if(m_doMirrorData)
			{
				string mirrorSuffix;
				if(m_isExporter)
					mirrorSuffix = ".exported.xml";
				else
					mirrorSuffix = ".imported.xml";

				SaveFile(fileName + mirrorSuffix,apDoc);
				isOk = true;
			}
			
			if(m_doUpdateSource)
			{
				if(!m_isExporter && m_fromMirror)
				{
					string suffix = ".exported.xml";
					string newFileName = fileName;
					
					string::size_type pos = newFileName.rfind(suffix);
					if(string::npos != pos)
					{
						newFileName.replace(pos,suffix.length(),"");
						SaveFile(newFileName,apDoc);
						isOk = true;
					}
					else
					{
						throw Exception(string("Unexpected file name: ") + fileName);
					}
				}
				else
				{
					SaveFile(fileName,apDoc);
					isOk = true;
				}
			}
		}
		else
		{
			isOk = true;
		}
	}
	catch (Exception& x)
	{
		m_logger.error() << __FUNCTION__ << " : " <<  x.displayText() << endl;
		isOk = false;
	}
	catch (exception& x)
	{
		m_logger.error() << __FUNCTION__ << " : " <<  x.what() << endl;
		isOk = false;
	}

	return isOk;
}

void 
CServerPasswordTransformer::SaveFile(const string& fileName,AutoPtr<Document>& apDoc)
{
	if(fileName.empty())
		throw Exception("Empty file name");

	try
	{
		FileOutputStream fos(fileName);
		if(fos.good())
		{
			DOMWriter writer;
			writer.setNewLine("\n");
			writer.setOptions(XMLWriter::PRETTY_PRINT);
			writer.writeNode(fos, apDoc);
			fos.close();
		}
		else
			throw Exception("Could not save file");
	}
	catch(Exception& x)
	{
		m_logger.error() << __FUNCTION__ << " : " <<  x.displayText() << endl;
		throw;
	}
}