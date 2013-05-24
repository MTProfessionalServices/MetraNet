// dllmain.h : Declaration of module class.
#pragma once

class CVertexATLWrapperModule : public ATL::CAtlDllModuleT< CVertexATLWrapperModule >
{
public :
	DECLARE_LIBID(LIBID_VertexATLWrapperLib)
	DECLARE_REGISTRY_APPID_RESOURCEID(IDR_VERTEXATLWRAPPER, "{485D47DB-AA45-4977-B73F-C4FB9F218C9C}")
};

extern class CVertexATLWrapperModule _AtlModule;

