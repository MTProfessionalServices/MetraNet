
#include "RsaKmcCertPasswordEncryptor.h"


static string gMtSecurityFileName = "mtsecurity.xml";


CRsaKmcCertPasswordEncryptor::CRsaKmcCertPasswordEncryptor()
{
	m_name = "EncryptRsaKmcCertPass";
	m_description = "Encrypts the user provided password for the RSA KMS client certificate";
}

CRsaKmcCertPasswordEncryptor::~CRsaKmcCertPasswordEncryptor()
{
}

void 
CRsaKmcCertPasswordEncryptor::ClearParams()
{
	m_rsaKmcCertPass.clear();
	m_fileDir.clear();
}

bool 
CRsaKmcCertPasswordEncryptor::GetParams(AutoPtr<AbstractConfiguration> spParams)
{
	bool isOk = false;
	try
	{
		if(!spParams->hasProperty("params.password"))
			throw Exception("Missing parameter");

		m_rsaKmcCertPass = spParams->getString("params.password");
        if(m_rsaKmcCertPass.empty())
            throw Exception("Empty parameter");

		if(!spParams->hasProperty("params.path"))
			throw Exception("Missing parameter");

		m_fileDir = spParams->getString("params.path");

		isOk = true;
	}
	catch(Exception& x)
	{
		m_logger.error() << __FUNCTION__ << " : " << x.displayText() << endl;
	}
	return isOk;
}

bool
CRsaKmcCertPasswordEncryptor::Execute(AutoPtr<AbstractConfiguration> spParams)
{
	bool isOk = false;

	if(spParams.isNull())
		return isOk;

	try
	{
		ClearParams();
		if(!GetParams(spParams))
			throw Exception("Bad parameters");

        vector<string> filePaths;
		if(!FindFiles(m_fileDir,gMtSecurityFileName,filePaths))
			throw Exception("Error finding server files");

		size_t max = filePaths.size();
		for(size_t i = 0;i < max;i++)
		{
			if(!ProcessFile(filePaths[i],"kmsCertificatePwd"))
				m_logger.warning() << __FUNCTION__ << " : Error processing " << filePaths[i] << endl;
		}
	}
	catch(Exception& x)
	{
		m_logger.error() << __FUNCTION__ << " : " << x.displayText() << endl;
	}

	ClearParams();

	return isOk;
}

bool
CRsaKmcCertPasswordEncryptor::FindFiles(const string& path,const string& name,vector<string>& files)
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
CRsaKmcCertPasswordEncryptor::ProcessFile(const string& fileName,const string& tagName)
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
                        string enc = CMsDataProtector::Encrypt(m_rsaKmcCertPass);
                        if(!enc.empty())
                        {
							AutoPtr<Text> apText = apDoc->createTextNode(enc);

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

							pElem->setAttribute("encrypted","true");
							changedFields = true;
                        }
                        else
                        {
                            throw Exception("Could not process field");
                        }
					}
				}
			}
		}

		if(changedFields)
		{
            SaveFile(fileName,apDoc);
			isOk = true;
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
CRsaKmcCertPasswordEncryptor::SaveFile(const string& fileName,AutoPtr<Document>& apDoc)
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