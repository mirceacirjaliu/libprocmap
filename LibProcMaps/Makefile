

YACC = bison

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

test : test.c libprocmap.a
	$(CC) -O0 -g3 -o test test.c libprocmap.a

.PHONY: clean

clean:
	rm -f *.a *.o *.tab.* *.yy.* test
