#!/bin/sh

SRC="./src/alter.c ./src/analyze.c ./src/attach.c ./src/auth.c ./src/backup.c ./src/bitvec.c ./src/btmutex.c ./src/btree.c ./src/btree.h ./src/btreeInt.h ./src/build.c ./src/callback.c ./src/complete.c ./src/ctime.c ./src/date.c ./src/dbpage.c ./src/dbstat.c ./src/delete.c ./src/expr.c ./src/fault.c ./src/fkey.c ./src/func.c ./src/global.c ./src/hash.c ./src/hash.h ./src/hwtime.h ./src/insert.c ./src/legacy.c ./src/loadext.c ./src/main.c ./src/malloc.c ./src/mem0.c ./src/mem1.c ./src/mem2.c ./src/mem3.c ./src/mem5.c ./src/memdb.c ./src/memjournal.c ./src/msvc.h ./src/mutex.c ./src/mutex.h ./src/mutex_noop.c ./src/mutex_unix.c ./src/mutex_w32.c ./src/notify.c ./src/os.c ./src/os.h ./src/os_common.h ./src/os_setup.h ./src/os_unix.c ./src/os_win.c ./src/os_win.h ./src/pager.c ./src/pager.h ./src/parse.y ./src/pcache.c ./src/pcache.h ./src/pcache1.c ./src/pragma.c ./src/pragma.h ./src/prepare.c ./src/printf.c ./src/random.c ./src/resolve.c ./src/rowset.c ./src/select.c ./src/status.c ./src/shell.c.in ./src/sqlite.h.in ./src/sqlite3ext.h ./src/sqliteInt.h ./src/sqliteLimit.h ./src/table.c ./src/tclsqlite.c ./src/threads.c ./src/tokenize.c ./src/treeview.c ./src/trigger.c ./src/utf.c ./src/update.c ./src/upsert.c ./src/util.c ./src/vacuum.c ./src/vdbe.c ./src/vdbe.h ./src/vdbeapi.c ./src/vdbeaux.c ./src/vdbeblob.c ./src/vdbemem.c ./src/vdbesort.c ./src/vdbetrace.c ./src/vdbevtab.c ./src/vdbeInt.h ./src/vtab.c ./src/vxworks.h ./src/wal.c ./src/wal.h ./src/walker.c ./src/where.c ./src/wherecode.c ./src/whereexpr.c ./src/whereInt.h ./src/window.c ./ext/fts1/fts1.c ./ext/fts1/fts1.h ./ext/fts1/fts1_hash.c ./ext/fts1/fts1_hash.h ./ext/fts1/fts1_porter.c ./ext/fts1/fts1_tokenizer.h ./ext/fts1/fts1_tokenizer1.c ./ext/fts2/fts2.c ./ext/fts2/fts2.h ./ext/fts2/fts2_hash.c ./ext/fts2/fts2_hash.h ./ext/fts2/fts2_icu.c ./ext/fts2/fts2_porter.c ./ext/fts2/fts2_tokenizer.h ./ext/fts2/fts2_tokenizer.c ./ext/fts2/fts2_tokenizer1.c ./ext/fts3/fts3.c ./ext/fts3/fts3.h ./ext/fts3/fts3Int.h ./ext/fts3/fts3_aux.c ./ext/fts3/fts3_expr.c ./ext/fts3/fts3_hash.c ./ext/fts3/fts3_hash.h ./ext/fts3/fts3_icu.c ./ext/fts3/fts3_porter.c ./ext/fts3/fts3_snippet.c ./ext/fts3/fts3_tokenizer.h ./ext/fts3/fts3_tokenizer.c ./ext/fts3/fts3_tokenizer1.c ./ext/fts3/fts3_tokenize_vtab.c ./ext/fts3/fts3_unicode.c ./ext/fts3/fts3_unicode2.c ./ext/fts3/fts3_write.c ./ext/icu/sqliteicu.h ./ext/icu/icu.c ./ext/rtree/rtree.h ./ext/rtree/rtree.c ./ext/rtree/geopoly.c ./ext/session/sqlite3session.c ./ext/session/sqlite3session.h ./ext/userauth/userauth.c ./ext/userauth/sqlite3userauth.h ./ext/rbu/sqlite3rbu.h ./ext/rbu/sqlite3rbu.c ./ext/misc/json1.c ./ext/misc/stmt.c keywordhash.h opcodes.c opcodes.h parse.c parse.h config.h shell.c sqlite3.h"

gcc  -g -O2 -o mksourceid ./tool/mksourceid.c
tclsh8.6 ./tool/mksqlite3h.tcl . >sqlite3.h
gcc  -g -O2 -o mkkeywordhash -DSQLITE_ENABLE_MATH_FUNCTIONS  ./tool/mkkeywordhash.c
./mkkeywordhash >keywordhash.h
gcc  -g -O2 -o lemon ./tool/lemon.c
cp ./tool/lempar.c .
cp ./src/parse.y .
./lemon -DSQLITE_ENABLE_MATH_FUNCTIONS  -S parse.y
cat parse.h ./src/vdbe.c | tclsh8.6 ./tool/mkopcodeh.tcl >opcodes.h
tclsh8.6 ./tool/mkopcodec.tcl opcodes.h >opcodes.c
tclsh8.6 ./tool/mkshellc.tcl >shell.c
cp ./ext/fts5/fts5parse.y .
rm -f fts5parse.h
./lemon  -S fts5parse.y
tclsh8.6 ./ext/fts5/tool/mkfts5c.tcl
cp ./ext/fts5/fts5.h .
rm -rf tsrc
mkdir tsrc

cp -f $SRC tsrc
rm tsrc/sqlite.h.in tsrc/parse.y
tclsh8.6 ./tool/vdbe-compress.tcl  <tsrc/vdbe.c >vdbe.new
mv vdbe.new tsrc/vdbe.c
cp fts5.c fts5.h tsrc
touch .target_source
tclsh8.6 ./tool/mksqlite3c.tcl
cp tsrc/sqlite3ext.h .
cp ./ext/session/sqlite3session.h .

CFLAGS="gcc -g -O2 -DSQLITE_OS_UNIX=1 -I. -I./src -I./ext/rtree -I./ext/icu -I./ext/fts3 -I./ext/async -I./ext/session -I./ext/userauth -D_HAVE_SQLITE_CONFIG_H -DBUILD_sqlite -DNDEBUG -I/usr/include/tcl8.6 -DSQLITE_THREADSAFE=1 -DSQLITE_ENABLE_MATH_FUNCTIONS -DSQLITE_HAVE_ZLIB=1"

libtool --mode=compile --tag=CC $CFLAGS -DSQLITE_TEMP_STORE=1 -c sqlite3.c
libtool --mode=link $CFLAGS -no-undefined -o libsqlite3.la sqlite3.lo -lm -ldl -lz -lpthread -rpath "/usr/local/lib" -version-info "8:6:8"
libtool --mode=link $CFLAGS -DHAVE_READLINE=1 -I/usr/include/readline -DHAVE_EDITLINE=0 -DSQLITE_ENABLE_JSON1 -DSQLITE_ENABLE_FTS4 -DSQLITE_ENABLE_RTREE -DSQLITE_ENABLE_EXPLAIN_COMMENTS -DSQLITE_ENABLE_UNKNOWN_SQL_FUNCTION -DSQLITE_ENABLE_STMTVTAB -DSQLITE_ENABLE_DBPAGE_VTAB -DSQLITE_ENABLE_DBSTAT_VTAB -DSQLITE_ENABLE_BYTECODE_VTAB -DSQLITE_ENABLE_OFFSET_SQL_FUNC -DSQLITE_ENABLE_DESERIALIZE -o sqlite3 \
	shell.c sqlite3.c \
	-lreadline -lncurses  -lm -ldl -lz -lpthread   -rpath "/usr/local/lib"

libtool --mode=compile --tag=CC $CFLAGS -DUSE_TCL_STUBS=1 -c ./src/tclsqlite.c
libtool --mode=link $CFLAGS   -no-undefined -o libtclsqlite3.la tclsqlite.lo \
	libsqlite3.la -L/usr/lib/x86_64-linux-gnu -ltclstub8.6 -lm -ldl -lz -lpthread   \
	-rpath "/usr/share/tcltk/tcl8.6/sqlite3" \
	-version-info "8:6:8" \
	-avoid-version

# Not using GNU parallel because of dependencies between commands