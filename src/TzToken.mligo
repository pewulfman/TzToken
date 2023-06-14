#import "interfaces/FA1.2.mligo" "FA1"
#import "interfaces/FA2.mligo" "FA2"
module Errors = struct
let contractNotFound = "Contract not found"

let notEnoughToken = "Not enough token transfered to contract"

let tooMuchToken = "Too much token transfered to contract"

let wrongSender = "CannotTransfertTezFromOtherThanTheSender"
 end

type t =
[@layout comb]
| Xtz of unit | Fa1 of address | Fa2 of {address : address; id : nat}

type tzAmount = [@layout comb] {currency : t; amount : nat}

type tzRecipient =
  [@layout comb] {currency : t; amount : nat; recipient : address}

let transfer
  (contract : t)
  (sender : address)
  (receiver : address)
  (amount : nat) =
  match contract with
    Xtz ->
      let contract = Tezos.get_self_address () in
      let amount = amount * 1mutez in
      let received_amount = Tezos.get_amount () in
      let () =
        if (sender <> contract)
        then
          (let () =
             if (Tezos.get_sender () <> sender) then failwith Errors.wrongSender in
           if (received_amount < amount)
           then failwith Errors.notEnoughToken
           else if (received_amount > amount) then failwith Errors.tooMuchToken)
        else (()) in
      if (receiver = contract)
      then (None)
      else
        (match (Tezos.get_contract_opt receiver : unit contract option) with
           Some contract -> Some (Tezos.transaction () amount contract)
         | None -> failwith Errors.contractNotFound)
  | Fa1 (address) ->
      (match (Tezos.get_entrypoint_opt "%transfer" address
              : FA1.transfer contract option)
       with
         Some contract ->
           Some (Tezos.transaction (sender, (receiver, amount)) 0mutez contract)
       | None -> failwith Errors.contractNotFound)
  | Fa2 {address = address; id = id} ->
      (match (Tezos.get_entrypoint_opt "%transfer" address
              : FA2.transfer contract option)
       with
         Some contract ->
           Some
             (Tezos.transaction
                [{from_ = sender;
                  tx = [{to_ = receiver; token_id = id; amount = amount}]}]
                0mutez
                contract)
       | None -> failwith Errors.contractNotFound)

let to_op_list (lst : operation option list) =
  List.fold_left
    (fun (acc, op) ->
       match (op : operation option) with
         (Some op) -> op :: acc
       | None -> acc)
    []
    lst
