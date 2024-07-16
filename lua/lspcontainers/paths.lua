-- convert dos path to unix path
local function dos2UnixSafePath(workdir)
    workdir = string.gsub(workdir, ":", "")
    workdir = string.gsub(workdir, "\\", "/")
    workdir = "/" .. workdir
    return workdir
end

return {
    dos2UnixSafePath = dos2UnixSafePath
}
