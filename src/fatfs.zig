const st = @import("stm32cubemx");

pub const Error = error{MountFailed};

pub fn mount(fs: *st.FATFS, path: [:0]const u8, immediate: bool) Error!void {
    if (st.f_mount(fs, path.ptr, if (immediate) 1 else 0) != st.FR_OK) return Error.MountFailed;
}

pub const Directory = struct {
    pub const Error = error{
        OpenFailed,
        ReadFailed,
    };

    handle: st.DIR,

    pub fn open(path: [:0]const u8) Directory.Error!Directory {
        var self: Directory = undefined;
        return if (st.f_opendir(&self.handle, path.ptr) == st.FR_OK) self else Directory.Error.OpenFailed;
    }

    pub fn close(self: *Directory) void {
        _ = st.f_closedir(&self.handle);
    }

    pub fn read(self: *Directory) Directory.Error!st.FILINFO {
        var file_info: st.FILINFO = undefined;
        return if (st.f_readdir(&self.handle, &file_info) == st.FR_OK) file_info else Directory.Error.ReadFailed;
    }
};

pub const File = struct {
    pub const Error = error{
        OpenFailed,
        ReadFailed,
        SeekFailed,
    };

    handle: st.FIL,

    pub fn open(path: [:0]const u8, mode: u8) File.Error!File {
        var self: File = undefined;
        return if (st.f_open(&self.handle, path.ptr, mode) == st.FR_OK) self else File.Error.OpenFailed;
    }

    pub fn close(self: *File) void {
        _ = st.f_close(&self.handle);
    }

    pub fn read(self: *File, buffer: []u8) File.Error!usize {
        var res: usize = 0;
        return if (st.f_read(&self.handle, buffer.ptr, buffer.len, &res) == st.FR_OK) res else File.Error.ReadFailed;
    }

    pub fn seek(self: *File, offset: usize) File.Error!void {
        if (st.f_lseek(&self.handle, offset) != st.FR_OK) return File.Error.SeekFailed;
    }

    pub fn tell(self: *File) usize {
        return st.f_tell(&self.handle);
    }

    pub fn size(self: *File) usize {
        return st.f_size(&self.handle);
    }

    pub fn errorCode(self: *File) u8 {
        return st.f_error(&self.handle);
    }
};
