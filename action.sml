
structure Self =
   struct

      type 'a self = { text : 'a,
                       code : 'a,
                       math : 'a,
                       comment : 'a }

   end
   

signature ACTION =
   sig
      type action
      type command
      type mode
      type pos

      val action : (string * mode Self.self * pos -> command) -> action

      val seq : command list -> command
      val put : string -> command
      val push_mode : mode -> command
      val pop_mode : pos -> command
      val illegal : pos -> command

      val simple : string -> action
      (* simple str = action (fn _ => put str) *)
   end
