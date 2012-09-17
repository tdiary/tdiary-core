#! /usr/bin/ruby1.9.1 -s
#######
# rdswap.rb (c) C.Hintze <c.hintze@gmx.net> 30.08.1999
#######


require "ostruct";

if ARGV.size < 2 and not ($h or $help)
    print "Wrong # of paramter! Use `-h' for help.\n";
    exit 1;
elsif $h or $help
    print eval('"'+DATA.read+'"');
    exit 0;
end   

srcfile = ARGV.select{|fn| fn =~ /\.rb$/o};
case srcfile.size
when 0
    $stderr.print "Warning: No `.rb' file given! Take first file as source.\n";
    srcfile = ARGV[0];
when 1
    srcfile = srcfile[0];
else
    print "Sorry! Only one source file (`.rb') allowed!\n";
    exit(1);
end

docs = {};
srcs = {};

rddoc, rddocs = nil, [];
source, sources = [], [[]];

while gets
    lang = $1 if File::basename(String($<)) =~ /^.*?([^.]+)$/o;
    if /^=begin/o .. /^=end/o
        title = $2 if /^=begin(\s+(.*))?$/o;
        unless rddoc.nil?
            unless /^=end/o
                rddoc.lines << $_;
            else
                rddocs << rddoc;
            	sources << [];
                rddoc = nil;
            	title = nil;
            end
        else               # New RD block found! Instantiate data container.
            rddoc = OpenStruct.new
            rddoc.kind, rddoc.lines = title, [];
        end
    else                   # It is not a RD block means, it is a source line!
        sources[-1] << $_;
    end
    if $<.eof?             # One file finished. Remember data and proceed.
        docs[lang] = rddocs;
        srcs[lang] = sources;
        rddoc, rddocs = nil, [];
        source, sources = [], [[]];
    end
end

langs = docs.keys;
langs.delete("rb");        # `rb' is not a language but the script!
source = srcs["rb"];       # Assign it for preventing later look-ups
srcdoc = docs["rb"];
sourcesize = source.size;  # Do not recalculate size again and again.
srcdocsize = srcdoc.size;

for lang in langs
    docblk = docs[lang];
	max = [sourcesize, srcdocsize, docblk.size].max;
    filename = File.join(srcfile+"."+lang);
    open(filename, "w+") do |fd|
        j = 0;
        for i in 0...max   # Goto every block; be it source or RD.
            fd.print source[i].join unless source[i].nil? || source[i].empty?;
            sblk, dblk = srcdoc[i], docblk[j];
            blk = (dblk and (dblk.kind == sblk.kind)) ? dblk : sblk;
			next unless blk;
            j += 1 if blk == dblk;
            fd.print "=begin #{blk && blk.kind}\n", blk.lines.join, "=end\n";
        end
    end
    print "File `#{filename}' created.\n" if $v;
end

exit(0);

__END__

Purpose:
   This tool is written to support you to write multi-language documents
   using the Ruby-Document-Format (RD).

   The idea for such a tool was originated by
   
   		Minero Aoki <aamine@dp.u-netsurf.ne.jp>,
		
   how has thought about, how to make life easier for developers who have to
   write and maintain scripts in more than one language.

   You have to specify at least two filenames on the command line. One
   containing the Ruby script, the second containing a translated RD. If the
   script does *not* end with `.rb', it has to be the first filename mentioned
   on the command line! In opposition, all files containing translations *must
   not* ending with `.rb'! They should use a extension that describes the
   language. So that would give us the following picture:

      - sample.rb : Script contains the original documentation.
      - sample.jp : Documentation written in Japanese.
      - sample.de : Translation to German.

   The tool doesn't care about the language extensions. You can name them as
   you like! So the file containing the Japanese translation above, could also
   be names e.g. `sample.japan' or even `japantranslation.japan'.

   For every translation file, a new file will be created. The name is build
   from the script filename plus the language extension. So regarding the
   example above, following files would be created:

      - sample.rb.jp
      - sample.rb.de

   or, given the alternative translation filename as mentioned above...

      - sample.rb.japan

How does it work?
   The contents of all files will be split into source and RD blocks. The
   source of the translation files, will be discarded! Every RD block may
   be of a certain type. The type will be taken from the contents directly
   following the `=begin' on the same line. If there is only a lonely `=begin'
   on a line by itself, the type of the block is `nil'. That means in

        :
        =begin
         bla bla
        =end
        :
        =begin whatever or not
         blub blub
        =end
        :
   
   the first block would be of type `nil' and the second one of type `whatever
   or not'.
   
   Block types are important for the translation. If a source will be
   generated from a script and a translation file, only these blocks are taken
   from the translation files, that comes in the right sequence *and* contains
   the same type as the block in the script! For example:

        # File sample.rb
        :
        =begin gnark
         Some comment
        =end
        :
        =begin
         block 2
        =end
        :
        =begin
         block 3
        =end
        :

        # File sample.de
        :
        =begin
         Block zwei
        =end
        :
        =begin
         Block drei
        =end
        :

   Here, the first block of `sample.rb' will *not* be translated, as there is
   no translation block with that type in sample.de! So the first block would
   be inserted as-it-is into the translated script. The blocks afterwards,
   however, are translated as the block type does match (it is `nil' there).

   Attention: In a translation file, a second block will only be used, if
              a first one was already used (matched). A third block will
              only be used, if a second one was used already!

   That means, if the first block of `sample.de' would be of type e.g. `Never
   match', then no block would ever be taken to replace anyone of `sample.rb'.
   
Syntax:
   #{File::basename $0} [-h|-v] <filename>...

Whereby:
   -h  shows this help text.
   -v  shows some more text during processing.
   <filename>  Means a file, that contains RD and/or Ruby code.

Examples:
   #{File::basename $0} -v sample.rb sample.ja sample.de
   #{File::basename $0} -v sample.ja sample.rb sample.de
   #{File::basename $0} -v sample.ja sample.de sample.rb
   #{File::basename $0} -v sample.??

Author:
   Clemens Hintze <c.hintze@gmx.net>.
