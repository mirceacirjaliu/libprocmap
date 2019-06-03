
#ifndef __LIBPROCMAP_H__
#define __LIBPROCMAP_H__

#include <inttypes.h>

struct dev
{
	uint8_t major;
	uint8_t minor;
};

struct perms
{
	uint8_t read : 1;
	uint8_t write : 1;
	uint8_t execute : 1;
	uint8_t shared : 1;
};

struct memmap {
	uint64_t start;
	uint64_t end;

	struct perms perms;
	uint32_t offset;
	struct dev dev;

	uint32_t inode;
	char pathname[256];
};


int get_proc_map(int pid, void (*cb)(struct memmap*));

#endif /* __LIBPROCMAP_H__ */