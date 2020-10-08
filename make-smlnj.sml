
CM.make "sources.cm";

structure Go =
   struct
   
      val date = Date.toString (Date.fromTimeUniv (Time.now ())) ^ " UTC"
      val usage = "Usage: pretex <filename>\n"

      fun go (_, args) =
         (
         print "Pretex build ";
         print date;
         print "\n";

         (case args of
             [filename] => Main.main filename

           | [] => (print usage; OS.Process.failure)

           | _ :: _ :: _ => (print usage; OS.Process.failure))
         )

   end ;

SMLofNJ.exportFn ("bin/pretex-heapimg", Go.go)
