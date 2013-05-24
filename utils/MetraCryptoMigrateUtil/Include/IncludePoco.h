#ifndef _INCLUDE_POCO_H_
#define _INCLUDE_POCO_H_

#include "Poco/AutoPtr.h"
#include "Poco/SharedPtr.h"

#include "Poco/Exception.h"

#include "Poco/String.h"
#include "Poco/Format.h"

#include "Poco/UUIDGenerator.h"
#include "Poco/UUID.h"

#include "Poco/StringTokenizer.h"
#include "Poco/Base64Encoder.h"
#include "Poco/Base64Decoder.h"
#include "Poco/StreamCopier.h"
#include "Poco/DigestStream.h"

#include "Poco/SHA1Engine.h"
#include "Poco/MD5Engine.h"

#include "Poco/BinaryWriter.h"
#include "Poco/BinaryReader.h"

#include "Poco/Logger.h"
#include "Poco/LogStream.h"

#include "Poco/Util/Application.h"
#include "Poco/Util/Option.h"
#include "Poco/Util/OptionSet.h"
#include "Poco/Util/HelpFormatter.h"
#include "Poco/Util/AbstractConfiguration.h"

#include "Poco/NotificationCenter.h"
#include "Poco/Observer.h"
#include "Poco/NObserver.h"

#include "Poco/Util/LayeredConfiguration.h"
#include "Poco/Util/MapConfiguration.h"
#include "Poco/Util/PropertyFileConfiguration.h"

#include "Poco/Data/SessionFactory.h"
#include "Poco/Data/Session.h"
#include "Poco/Data/RecordSet.h"
#include "Poco/Data/Column.h"
#include "Poco/Data/TypeHandler.h"

#include "Poco/Data/SQLite/Connector.h"

#include "Poco/Data/ODBC/Connector.h"
#include "Poco/Data/ODBC/Utility.h"
#include "Poco/Data/ODBC/Diagnostics.h"
#include "Poco/Data/ODBC/ODBCException.h"

#include "Poco/File.h"
#include "Poco/Path.h"
#include "Poco/FileStream.h"
#include "Poco/DirectoryIterator.h"

#include "Poco/DOM/Document.h"
#include "Poco/DOM/Element.h"
#include "Poco/DOM/Text.h"
#include "Poco/DOM/AutoPtr.h"
#include "Poco/DOM/DOMWriter.h"
#include "Poco/XML/XMLWriter.h"
#include "Poco/DOM/DOMParser.h"
#include "Poco/DOM/NodeIterator.h"
#include "Poco/DOM/NodeFilter.h"
#include "Poco/SAX/InputSource.h"
#include "Poco/DOM/NodeList.h"
#include "Poco/DOM/NamedNodeMap.h"



using Poco::UInt32;

using Poco::XML::DOMParser;
using Poco::XML::InputSource;
using Poco::XML::Document;
using Poco::XML::NodeIterator;
using Poco::XML::NodeFilter;
using Poco::XML::Node;
using Poco::XML::NodeList;
using Poco::XML::Element;
using Poco::XML::Text;
using Poco::XML::DOMWriter;
using Poco::XML::XMLWriter;
using Poco::XML::NamedNodeMap;

using Poco::AutoPtr;
using Poco::SharedPtr;

using Poco::format;

using Poco::UUID;
using Poco::UUIDGenerator;

using Poco::StringTokenizer;
using Poco::Base64Encoder;
using Poco::Base64Decoder;
using Poco::StreamCopier;

using Poco::MD5Engine;
using Poco::SHA1Engine;
using Poco::DigestEngine;
using Poco::DigestOutputStream;

using Poco::BinaryWriter;
using Poco::BinaryReader;

using Poco::Exception;
using Poco::NotFoundException;

using Poco::Logger;
using Poco::LogStream;

using Poco::Util::Application;
using Poco::Util::Option;
using Poco::Util::OptionSet;
using Poco::Util::HelpFormatter;
using Poco::Util::AbstractConfiguration;
using Poco::Util::OptionCallback;

using Poco::NotificationCenter;
using Poco::AbstractObserver;
using Poco::Observer;
using Poco::NObserver;
using Poco::Notification;

using Poco::Util::AbstractConfiguration;
using Poco::Util::LayeredConfiguration;
using Poco::Util::MapConfiguration;
using Poco::Util::PropertyFileConfiguration;

using Poco::File;
using Poco::Path;
using Poco::DirectoryIterator;
using Poco::FileInputStream;
using Poco::FileOutputStream;

using namespace Poco::Data;

using Poco::Data::ODBC::Utility;
using Poco::Data::ODBC::ConnectionException;
using Poco::Data::ODBC::StatementException;
using Poco::Data::ODBC::StatementDiagnostics;

#endif
