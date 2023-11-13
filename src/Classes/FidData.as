class FidData
{
	CSystemFidFile@ fid;
	CMwNod@ nod;
	string filePath;
	string method;

	FidData() { }

    FidData(CSystemFidFile@ &in _fid, const string &in _filePath, const string &in _method) 
	{ 
		@fid = _fid;
		@nod = Fids::Preload(fid);
		filePath = _filePath;
		method = _method;
	}
}