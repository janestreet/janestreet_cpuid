open Core

(** It is currently an error to run this on a non AMD/Intel CPU.

    For what it's worth, ARM is a pain to do this on, but at least
    then we'd know at compile time that we're going to be running
    on ARM and could be a bit more clever.
 **)
type t =
  | Amd of Amd_cpuid.t
  | Intel of Intel_cpuid.t

val create : unit -> t Or_error.t
val canonical_identifier : t -> string

(** If you use a flag on both platforms go ahead and add it here.
    It would be really nice to generate these based on the shared
    functionality but we really don't use enough CPU feature flags
    to make that worth it.
 **)

(**
   Does the processor support the SSE3 instruction set extensions.

   Support starts with Celeron / Opteron.
 **)
val supports_sse3 : t -> bool

(**
   Does the processor support the SSE4.1 instruction set extensions.

   Note that this is different from the AMD flag SSE4A.

   Support starts with Penryn / Jaguar.
 **)
val supports_sse4_1 : t -> bool

(**
   Does the processor support the SSE4.2 instruction set extensions.

   Note that this is different from the AMD flag SSE4A.

   Support starts with Nehalem / Jaguar.
 **)
val supports_sse4_2 : t -> bool

(**
   Does the processor support the AVX instruction set extensions.

   Support starts with Sandy Bridge / Jaguar.
 **)
val supports_avx : t -> bool

(**
   Does the processor support the AVX2 instruction set extensions.

   Support starts with Haswell / Excavator.
 **)
val supports_avx2 : t -> bool

(**
   Does the processor support the PCLMULQDQ instruction.

   Supports starts with Sandy Bridge / Jaguar.
 **)
val supports_pclmulqdq : t -> bool

(**
   Does the processor support the FMA3 instruction set extensions.

   Support starts with Haswell / Piledriver.
 **)
val supports_fma : t -> bool

(**
   Module gateway into AMD specific flags and functionality.
 **)
module Amd = Amd_cpuid

(**
   Module gateway into Intel specific flags and functionality.
 **)
module Intel = Intel_cpuid

module Registers : sig
  type t

  val print : (t[@local]) -> unit
end

val arbitrary_leaf_and_subleaf : leaf:int -> subleaf:int -> (Registers.t[@local])
