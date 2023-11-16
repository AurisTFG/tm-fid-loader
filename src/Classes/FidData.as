class FidData
{
	CSystemFidFile@ fid;
	string filePath;
	string method;

	CMwNod@ nod;
	string folderPath;

	FidData() { }

    FidData(CSystemFidFile@ &in _fid, const string &in _filePath, const string &in _method) 
	{ 
		@fid = _fid;
		filePath = _filePath;
		method = _method;

		@nod = Fids::Preload(fid);
		folderPath = IO::FromDataFolder("Extract/" + filePath.Replace(fid.FileName, ""));
	}
}