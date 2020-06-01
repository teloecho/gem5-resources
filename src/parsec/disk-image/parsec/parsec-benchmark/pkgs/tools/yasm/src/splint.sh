#!/bin/sh
splint \
 +allglobals \
 -noeffect \
 -exportlocal \
 -predbool \
 -boolops \
 +boolint \
 +charint \
 -retvalint \
 -retvalother \
 -shiftimplementation \
 -shiftnegative \
 -fixedformalarray \
 +ansi89limits \
 +ansistrictlib \
 +trytorecover \
 -globs \
 -I. \
 -I/usr/local/include \
 -DHAVE_CONFIG_H \
 -Dlint \
 frontends/yasm/yasm-options.c \
 frontends/yasm/yasm.c \
 libyasm/arch.c \
 libyasm/assocdat.c \
 libyasm/bc-align.c \
 libyasm/bc-data.c \
 libyasm/bc-incbin.c \
 libyasm/bc-insn.c \
 libyasm/bc-org.c \
 libyasm/bc-reserve.c \
 libyasm/bytecode.c \
 libyasm/errwarn.c \
 libyasm/expr.c \
 libyasm/file.c \
 libyasm/floatnum.c \
 libyasm/hamt.c \
 libyasm/intnum.c \
 libyasm/inttree.c \
 libyasm/linemap.c \
 libyasm/md5.c \
 libyasm/mergesort.c \
 libyasm/phash.c \
 libyasm/section.c \
 libyasm/strcasecmp.c \
 libyasm/strsep.c \
 libyasm/symrec.c \
 libyasm/valparam.c \
 libyasm/value.c \
 libyasm/xmalloc.c \
 libyasm/xstrdup.c \
 modules/arch/lc3b/lc3barch.c \
 modules/arch/lc3b/lc3bbc.c \
 modules/arch/x86/x86arch.c \
 modules/arch/x86/x86bc.c \
 modules/arch/x86/x86expr.c \
 modules/arch/x86/x86id.c \
 modules/dbgfmts/codeview/cv-dbgfmt.c \
 modules/dbgfmts/codeview/cv-symline.c \
 modules/dbgfmts/codeview/cv-type.c \
 modules/dbgfmts/dwarf2/dwarf2-aranges.c \
 modules/dbgfmts/dwarf2/dwarf2-dbgfmt.c \
 modules/dbgfmts/dwarf2/dwarf2-info.c \
 modules/dbgfmts/dwarf2/dwarf2-line.c \
 modules/dbgfmts/null/null-dbgfmt.c \
 modules/dbgfmts/stabs/stabs-dbgfmt.c \
 modules/listfmts/nasm/nasm-listfmt.c \
 modules/objfmts/bin/bin-objfmt.c \
 modules/objfmts/coff/coff-objfmt.c \
 modules/objfmts/coff/win64-except.c \
 modules/objfmts/dbg/dbg-objfmt.c \
 modules/objfmts/elf/elf-objfmt.c \
 modules/objfmts/elf/elf-x86-amd64.c \
 modules/objfmts/elf/elf-x86-x86.c \
 modules/objfmts/elf/elf.c \
 modules/objfmts/macho/macho-objfmt.c \
 modules/objfmts/rdf/rdf-objfmt.c \
 modules/objfmts/xdf/xdf-objfmt.c \
 modules/parsers/gas/gas-parse.c \
 modules/parsers/gas/gas-parser.c \
 modules/parsers/nasm/nasm-parse.c \
 modules/parsers/nasm/nasm-parser.c \
 modules/preprocs/nasm/nasm-preproc.c \
 modules/preprocs/raw/raw-preproc.c

