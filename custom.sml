
structure Self =
   struct

      type 'a self = { text : 'a,
                       code : 'a,
                       math : 'a }

   end
   

(* Don't edit ACTION. *)
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



(* The following actions are built-in, others must be provided here:

   echo
   enter_code
   enter_text
   skip
   pop
   pop_echo
   terminate

   all actions for code mode

*)

functor CustomFun (structure Action : ACTION) =
   struct

      open Action

      val enter_math_echo =
         action
         (fn (match, self, _) =>
                 seq [push_mode (#math self),
                      put match])

      val arrow = simple "\\rightarrow "
      val bindcolon = simple "\\mathord{:}"
      val colon = simple ":"
      val turnstile = simple "\\vdash "
      val lambda = simple "\\lambda "

      val greekArr : string option array = Array.array (128, NONE)
      
      val () =
         app (fn (ch, str) => Array.update (greekArr, Char.ord ch, SOME str))
         [
         (#"a", "\\alpha "),
         (#"b", "\\beta "),
         (#"d", "\\delta "),
         (#"e", "\\epsilon "),
         (#"f", "\\phi "),
         (#"g", "\\gamma "),
         (#"h", "\\eta "),
         (#"i", "\\iota "),
         (#"k", "\\kappa"),
         (#"l", "\\lambda "),
         (#"m", "\\mu "),
         (#"n", "\\nu "),
         (#"p", "\\pi "),
         (#"r", "\\rho "),
         (#"s", "\\sigma "),
         (#"t", "\\tau "),
         (#"u", "\\upsilon "),
         (#"x", "\\xi "),
         (#"z", "\\zeta "),
         (#"D", "\\Delta "),
         (#"F", "\\Phi "),
         (#"G", "\\Gamma "),
         (#"L", "\\Lambda "),
         (#"P", "\\Pi "),
         (#"S", "\\Sigma "),
         (#"U", "\\Upsilon "),
         (#"X", "\\Xi "),

         (#"c", "\\chi "),
         (#"j", "\\varepsilon "),
         (#"o", "\\theta "),
         (#"q", "\\psi "),
         (#"v", "\\varphi "),
         (#"w", "\\omega "),
         (#"O", "\\Theta "),
         (#"Q", "\\Psi "),
         (#"W", "\\Omega ")
         ]

      (* All lower case letters used but y. *)

      val greek =
         action
         (fn (match, _, pos) =>
             (case Array.sub (greekArr, Char.ord (String.sub (match, 1))) of
                 NONE => illegal pos
               | SOME str => put str))
   
   end
