const bool DEV = Meta::ExecutingPlugin().Name.ToLower().EndsWith("(dev)");
const bool OP_DEV_MODE = Meta::IsDeveloperMode();

#if TMNEXT
const bool OP_EXTRACT_PERMISSION = OpenplanetHasFullPermissions();
#else
const bool OP_EXTRACT_PERMISSION = true;
#endif

const string WINDOW_LABEL = "\\$b1f" + Icons::FolderOpen + (DEV ? "\\$d00" : "\\$z") + " Fid Loader" + (DEV ? " (Dev)" : "");
