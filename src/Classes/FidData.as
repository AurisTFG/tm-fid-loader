class FidData
{
	CSystemFidFile@ fid;
	string filePath;
	string method;

	FidData() { }

    FidData(CSystemFidFile@ &in _fid, const string &in _filePath, const string &in _method) 
	{ 
		@fid = _fid;
		filePath = _filePath;
		method = _method;
	}
}