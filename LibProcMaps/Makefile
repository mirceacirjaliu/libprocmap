

YACC = bison
CFLAGS = -O0 -g3

OBJECTS = libprocmap.tab.o libprocmap.yy.o

libprocmap.a : $(OBJECTS)
	ar rcs libprocmap.a $(OBJECTS)

libprocmap.tab.c libprocmap.tab.h : libprocmap.y
	bison -d libprocmap.y

libprocmap.yy.c libprocmap.yy.h : libprocmap.l
	flex --outfile=libprocmap.yy.c --header-file=libprocmap.yy.h libprocmap.l

libprocmap.tab.o : libprocmap.tab.c libprocmap.yy.h
libprocmap.yy.o : libprocmap.yy.c libprocmap.tab.h

%.o : %.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

install : libprocmap.a
	mkdir -p /usr/local/lib
	install -m 0644 libprocmap.a /usr/local/lib/libprocmap.a

test : test.c libprocmap.a
	$(CC) $(CFLAGS) $(CPPFLAGS) -o test test.c libprocmap.a

.PHONY: clean install

clean:
	rm -f *.a *.o *.tab.* *.yy.* test
