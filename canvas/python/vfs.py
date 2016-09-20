import os
import errno
import stat
import traceback

import llfuse

'''
A virtual filesystem.

Simpler than using llfs directly.
'''


DIRECTORY, FILE = range(1, 3)

class Entry(llfuse.EntryAttributes):
    def __init__(self):
        super(Entry, self).__init__()
    
    def set_mode(self, mode):
        self.st_mode = mode
    
    def set_size(self, size):
        self.st_size = size
    
    def set_atime(self, atime):
        self.st_atime_ns = atime
    
    def set_ctime(self, ctime):
        self.st_ctime_ns = ctime
    
    def set_mtime(self, mtime):
        self.st_mtime_ns = mtime
    
    def set_gid(self, gid):
        self.st_gid = gid
    
    def set_uid(self, uid):
        self.st_uid = uid
    
    def set_inode(self, inode):
        self.st_ino = inode

def directory_entry():
    entry = Entry()
    entry.set_mode(stat.S_IFDIR | 0o755)
    entry.set_size(0)
    entry.set_gid(os.getgid())
    entry.set_uid(os.getuid())
    return entry

def file_entry(size):
    entry = Entry()
    entry.set_mode(stat.S_IFREG | 0o644)
    entry.set_size(size)
    entry.set_gid(os.getgid())
    entry.set_uid(os.getuid())
    return entry

def std_dir(elements):
    return (
        DIRECTORY, directory_entry(),
        elements
    )

def std_file(data):
    return (
        FILE, file_entry(len(data)),
        data
    )

def join_paths(*paths):
    path = '/'.join(paths)
    if path.startswith('/'):
        path = path[1:]
    return path

class VFS(llfuse.Operations):
    def __init__(self):
        super(VFS, self).__init__()

        self.inodes = [(llfuse.ROOT_INODE, '')]

    def get_contents(self, path):
        raise Exception('not implemented')

    def get_contents_check(self, path):
        try:
            typ, entry, elements = self.get_contents(path)
        except ValueError:
            raise llfuse.FUSEError(errno.ENOENT)
        except Exception as e:
            traceback.print_exc()
            raise llfuse.FUSEError(errno.ENOENT)
        else:
            return (typ, entry, elements)

    def find_path(self, this_inode):
        for inode, path in self.inodes:
            if inode == this_inode:
                return path

    def find_inode(self, this_path):
        for inode, path in self.inodes:
            if path == this_path:
                return inode

        inode = llfuse.ROOT_INODE + len(self.inodes)
        self.inodes.append((inode, this_path))
        return inode

    def getattr(self, inode, ctx=None):
        path = self.find_path(inode)
        typ, entry, elements = self.get_contents_check(path)
        entry.set_inode(inode)
        return entry

    def lookup(self, parent_inode, name, ctx=None):
        path = join_paths(self.find_path(parent_inode),
                          name.decode('utf-8'))
        inode = self.find_inode(path)
        return self.getattr(inode)

    def opendir(self, inode, ctx):
        path = self.find_path(inode)
        if path is None or self.get_contents_check(path)[0] != DIRECTORY:
            raise llfuse.FUSEError(errno.ENOENT)
        return inode

    def readdir(self, inode, offset):
        path = self.find_path(inode)
        typ, entry, elements = self.get_contents_check(path)

        try:
            name = elements[offset]
        except IndexError:
            return None
        else:
            c_path = join_paths(path, name)
            c_inode = self.find_inode(c_path)
            c_typ, c_entry, c_elements = self.get_contents_check(c_path)
            c_entry.set_inode(c_inode)
            yield (name.encode('utf-8'), c_entry, offset + 1)

    def open(self, inode, flags, ctx):
        path = self.find_path(inode)
        if path is None or self.get_contents_check(path)[0] != FILE:
            raise llfuse.FUSEError(errno.ENOENT)
        return inode

    def read(self, inode, offset, size):
        path = self.find_path(inode)
        typ, entry, data = self.get_contents_check(path)
        return data[offset:offset + size]
