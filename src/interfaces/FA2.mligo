(**
   This file implement the TZIP-12 protocol (a.k.a FA2) on Tezos
   copyright Wulfman Corporation 2021
*)

module Operators = struct
   type owner    = address
   type operator = address
   type token_id = nat
   type t = ((owner * operator), token_id set) big_map
end

module Collection = struct
   type token_id = nat
   type amount_  = nat
   type t = (token_id, amount_) map
end
module Ledger = struct
   type owner = address
   type t = (owner, Collection.t) big_map
end

module TokenMetadata = struct
   type data = {token_id:nat;token_info:(string,bytes)map}
   type t = (nat, data) big_map
end

module Storage = struct
   type token_id = nat
   type t = {
      ledger : Ledger.t;
      token_metadata : TokenMetadata.t;
      operators : Operators.t;
   }
end


type storage = Storage.t
type atomic_trans = [@layout:comb] {
   to_      : address;
   token_id : nat;
   amount   : nat;
}

type transfer_from = {
   from_ : address;
   tx    : atomic_trans list
}
type transfer = transfer_from list
type request = {
   owner    : address;
   token_id : nat;
}

type callback = [@layout:comb] {
   request : request;
   balance : nat;
}
type balance_of = [@layout:comb] {
   requests : request list;
   callback : callback list contract;
}
type operator = [@layout:comb] {
   owner    : address;
   operator : address;
   token_id : nat;
}

type unit_update      = Add_operator of operator | Remove_operator of operator
type update_operators = unit_update list
