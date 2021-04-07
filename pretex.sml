
signature TRANSLATE =
   sig
      exception Error
      val translate : TextIO.outstream -> char Stream.stream -> unit
   end

structure Translate :> TRANSLATE =
   struct

      type 'a stream = 'a Stream.stream
      datatype front = datatype Stream.front
      val front = Stream.front

      type pos = int

      structure Table = HashTable (structure Key = StringHashable)

      val commandTable : (pos -> unit) Table.table = Table.table 23

      exception Error
      fun error pos str =
         (
         print "Translation error at position ";
         print (Int.toString pos);
         print ": ";
         print str;
         print "\n";
         raise Error
         )

      val currentOutstream : TextIO.outstream ref =
         ref TextIO.stdOut

      fun write str = TextIO.output (!currentOutstream, str)

      fun writeNewlines l =
         List.app
            (fn #"\n" => write "%\n"
              | _ => ())
            l
      
      type lexer = char stream -> pos -> char stream * pos

      val lexerStack : lexer list ref = ref nil

      fun continue strm pos =
         (case !lexerStack of
             lex :: _ => lex strm pos

           | _ =>
                raise (Fail "empty lexer stack"))

      fun pushmode lex =
         lexerStack := lex :: (!lexerStack)

      fun popmode pos =
         (case !lexerStack of
             [_] =>
                error pos "popping empty stack"

           | _ :: t => lexerStack := t

           | nil => raise (Fail "empty lexer stack"))

      structure LexArg =
         struct

            type symbol = char
            val ord = Char.ord

            type t = pos -> char stream * pos

            type self = lexer Self.self

            type info = { match : char list,
                          len : int,
                          start : char stream,
                          follow : char stream,
                          self : self }
      

            fun simple str ({follow, len, ...}:info) pos =
               (
               write str;
               continue follow (pos+len)
               )


            fun terminate ({start, ...}:info) pos =
               (start, pos)

            fun skip ({match, follow, len, ...}:info) pos =
               (
               writeNewlines match;
               continue follow (pos+len)
               )

            fun echo ({match, follow, len, ...}:info) pos =
               (
               write (String.implode match);
               continue follow (pos+len)
               )

            fun pop ({follow, len, self, ...}:info) pos =
               (
               popmode pos;
               continue follow (pos+len)
               )

            fun pop_echo ({match, follow, len, self, ...}:info) pos =
               (
               popmode pos;
               write (String.implode match);
               continue follow (pos+len)
               )



            (* text mode *)

            fun enter_text ({self, follow, len, ...}:info) pos =
               (
               pushmode (#text self);
               continue follow (pos+len)
               )


            (* code mode *)

            fun enter_code ({self, follow, len, ...}:info) pos =
               (
               pushmode (#code self);
               write "\\begin{code}";
               continue follow (pos+len)
               )
               
            fun exit_code ({self, follow, len, ...}:info) pos =
               (
               popmode pos;
               write "\\end{code}";
               continue follow (pos+len)
               )

            val code_tab = simple "\\ptCodeTab "
            val code_space = simple "\\ptCodeSpace "
            val code_newline = simple "\\ptCodeNewline "
      
            val codeArr : string array = Array.array (128, "")
      
            val () =
               app (fn (ch, str) => Array.update (codeArr, Char.ord ch, str))
               [
               (#"#", "\\#"),
               (#"$", "\\$"),
               (#"%", "\\%"),
               (#"&", "\\&"),
               (#"\\", "\\ptBackslash "),
               (#"^", "\\^"),
               (#"_", "\\_"),
               (#"~", "\\ptTilde "),
               (#"{", "\\ptLbrace "),
               (#"}", "\\ptRbrace ")
               ]
      
            fun code_symbol ({match, follow, len, ...}:info) pos =
               (
               write (Array.sub (codeArr, Char.ord (hd match)));
               continue follow (pos+len)
               )
            

            (* comment mode *)

            fun enter_comment ({self, follow, len, ...}:info) pos =
               (
               pushmode (#comment self);
               continue follow (pos+len)
               )



            (* custom actions *)

            structure Custom =
               CustomFun (structure Action =
                             struct
              
                                type action = info -> t
                                type command = unit -> unit
                                type mode = lexer
                                type pos = pos
              
                                fun action f ({match, self, follow, len, ...}:info) pos =
                                   (
                                   f (String.implode match, self, pos) ();
                                   continue follow (pos+len)
                                   )
              
                                fun seq l () = app (fn f => f ()) l
              
                                fun put str () = write str
              
                                fun push_mode lex () =
                                   pushmode lex
              
                                fun pop_mode pos () =
                                   popmode pos
              
                                fun illegal pos () =
                                   error pos "illegal lexeme"

                                val simple = simple
              
                             end)

            open Custom

         end

      structure Lex = LexFun (structure Streamable = StreamStreamable
                              structure Arg = LexArg)

      fun translate outs strm =
         let
            val () =
               currentOutstream := outs

            val () =
               lexerStack := [Lex.text]

            val (strm', pos) = Lex.text strm 0
         in
            (case front strm' of
                Nil =>
                  (case !lexerStack of
                     [_] => ()

                   | _ :: _ :: _ =>
                       error pos "unexpected end-of-file"

                   | nil =>
                       raise (Fail "impossible"))

              | Cons _ => error pos "illegal lexeme")
         end

   end


structure Main =
   struct
      
      exception Error = Translate.Error

      fun main infile =
         let
            val outfile = infile ^ ".tex"

            val ins =
               TextIO.openIn infile
               handle IO.Io _ =>
                  (
                  print "Error opening input file ";
                  print infile;
                  print "\n";
                  raise Error
                  )

            val outs =
               TextIO.openOut outfile
               handle IO.Io _ =>
                  (
                  print "Error opening output file ";
                  print outfile;
                  print "\n";
                  raise Error
                  )
         in
            Translate.translate outs (Stream.fromTextInstream ins)
            handle Error =>
               (
               TextIO.closeIn ins;
               raise Error
               );

            TextIO.closeIn ins;
            TextIO.closeOut outs;
            print outfile;
            print " written\n";
            OS.Process.success
         end
         handle Error => OS.Process.failure

   end
