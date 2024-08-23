open Base
open Core

module type S = Cpuid_intf.S

module Amd = Amd_cpuid
module Intel = Intel_cpuid

type t =
  | Amd of Amd_cpuid.t
  | Intel of Intel_cpuid.t

module Maximum_value_and_brand = struct
  type t =
    { mutable maximum_value : int
    ; mutable brand : string
    }
  [@@deriving sexp_of]

  let empty () = { maximum_value = 0; brand = "" }

  external _get : t -> unit = "cpuid_maximum_value_and_brand"

  let retrieve () =
    let t = empty () in
    let () = _get t in
    t
  ;;
end

let create () : t Or_error.t =
  let value = Maximum_value_and_brand.retrieve () in
  match value.brand with
  | "GenuineIntel" ->
    Ok
      (Intel_cpuid.create
         { Cpuid_intf.Basic_info.maximum_value = value.maximum_value
         ; brand = value.brand
         }
       |> Intel)
  | "AuthenticAMD" | "AMDisbetter!" ->
    Ok
      (Amd_cpuid.create
         { Cpuid_intf.Basic_info.maximum_value = value.maximum_value
         ; brand = value.brand
         }
       |> Amd)
  | _ -> Or_error.error_string "Running on an unknown architecture"
;;

let canonical_identifier = function
  | Amd t -> Amd_cpuid.canonical_identifier t
  | Intel t -> Intel_cpuid.canonical_identifier t
;;

let supports_sse3 = function
  | Amd _ ->
    let open Amd_cpuid.Version_and_feature_information in
    (retrieve ()).ecx |> Ecx_flags.do_intersect Ecx_flags.sse3
  | Intel _ ->
    let open Intel_cpuid.Version_and_feature_information in
    (retrieve ()).ecx |> Ecx_flags.do_intersect Ecx_flags.sse3
;;

let supports_sse4_1 = function
  | Amd _ ->
    let open Amd_cpuid.Version_and_feature_information in
    (retrieve ()).ecx |> Ecx_flags.do_intersect Ecx_flags.sse4_1
  | Intel _ ->
    let open Intel_cpuid.Version_and_feature_information in
    (retrieve ()).ecx |> Ecx_flags.do_intersect Ecx_flags.sse4_1
;;

let supports_sse4_2 = function
  | Amd _ ->
    let open Amd_cpuid.Version_and_feature_information in
    (retrieve ()).ecx |> Ecx_flags.do_intersect Ecx_flags.sse4_2
  | Intel _ ->
    let open Intel_cpuid.Version_and_feature_information in
    (retrieve ()).ecx |> Ecx_flags.do_intersect Ecx_flags.sse4_2
;;

let supports_avx = function
  | Amd _ ->
    let open Amd_cpuid.Version_and_feature_information in
    (retrieve ()).ecx |> Ecx_flags.do_intersect Ecx_flags.avx
  | Intel _ ->
    let open Intel_cpuid.Version_and_feature_information in
    (retrieve ()).ecx |> Ecx_flags.do_intersect Ecx_flags.avx
;;

let supports_pclmulqdq = function
  | Amd _ ->
    let open Amd_cpuid.Version_and_feature_information in
    (retrieve ()).ecx |> Ecx_flags.do_intersect Ecx_flags.pclmulqdq
  | Intel _ ->
    let open Intel_cpuid.Version_and_feature_information in
    (retrieve ()).ecx |> Ecx_flags.do_intersect Ecx_flags.pclmulqdq
;;

let supports_avx2 = function
  | Amd _ ->
    let open Amd_cpuid.Extended_feature_flags_subleaf_0 in
    (retrieve ()).ebx |> Ebx_flags.do_intersect Ebx_flags.avx2
  | Intel _ ->
    let open Intel_cpuid.Extended_feature_flags_subleaf_0 in
    (retrieve ()).ebx |> Ebx_flags.do_intersect Ebx_flags.avx2
;;

let supports_fma = function
  | Amd _ ->
    let open Amd_cpuid.Version_and_feature_information in
    (retrieve ()).ecx |> Ecx_flags.do_intersect Ecx_flags.fma
  | Intel _ ->
    let open Intel_cpuid.Version_and_feature_information in
    (retrieve ()).ecx |> Ecx_flags.do_intersect Ecx_flags.fma
;;

let supports_waitpkg = function
  | Amd _ -> false
  | Intel _ ->
    let open Intel_cpuid.Extended_feature_flags_subleaf_0 in
    (retrieve ()).ecx |> Ecx_flags.do_intersect Ecx_flags.waitpkg
;;

let supports_rtm = function
  | Amd _ -> false
  | Intel _ ->
    let open Intel_cpuid.Extended_feature_flags_subleaf_0 in
    (retrieve ()).ebx |> Ebx_flags.do_intersect Ebx_flags.rtm
;;

module Registers = struct
  type t =
    { eax : int
    ; ebx : int
    ; ecx : int
    ; edx : int
    }

  let print t =
    printf "EAX: %08x\n" t.eax;
    printf "EBX: %08x\n" t.ebx;
    printf "ECX: %08x\n" t.ecx;
    printf "EDX: %08x\n" t.edx
  ;;
end

external arbitrary_leaf_and_subleaf
  :  leaf:int
  -> subleaf:int
  -> local_ Registers.t
  = "cpuid_arbitrary_leaf_and_subleaf"
