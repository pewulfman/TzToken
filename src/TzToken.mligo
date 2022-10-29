(* Tezos FA abstraction layer
	copyright WULFMAN corporation 2022
*)

(*
	On tezos, tokens can be instanciate with different contract specification.
	This library aim to facilitate communication with crypto-monnaie with different specification.
*)

#import "interfaces/FA1.2.mligo" "FA1"
#import "interfaces/FA2.mligo" "FA2"

module Errors = struct
	let contractNotFound = "Contract not found"
	let notEnoughToken   = "Not enough token transfered to contract"
	let wrongSender      = "CannotTransfertTezFromOtherThanTheSender"
end

type t =
	Xtz of unit (* For handling native Tezos token *)
|	Fa1 of address (* For FA1.2 contract *)
|	Fa2 of (address * nat) (* For FA2 contract *)


let transfer (contract: t) (sender: address) (receiver: address) (amount:nat) =
	match contract with
		Xtz ->
			let contract = Tezos.get_self_address () in
			let amount = amount * 1mutez in
			(* Handling The native token is a special case which requires special logic *)
			let () = if (sender <> contract) then (
				(* Case 1:  The sender is not the contract
					check the quantity is correct and do a transaction *)
				let () = if (Tezos.get_sender () <> sender) then
					failwith Errors.wrongSender in
				if (Tezos.get_amount () < amount) then
					failwith Errors.notEnoughToken
			) else (
				(* Case 2: The sender is the contract.
					Check that there is enough balance.
					-> This is done by the protocol *)
				()
			) in
			if (receiver = contract) then (None (* do nothing, the protocol already sent the token in the transaction *))
			else (match (Tezos.get_contract_opt receiver : unit contract option) with
					Some contract ->
							Some (Tezos.transaction () amount contract)
				| 	None -> failwith Errors.contractNotFound
			)
	|	Fa1 (address) ->
		(match (Tezos.get_entrypoint_opt "%transfer" address : FA1.transfer contract option) with
			Some contract ->
				Some (Tezos.transaction (sender,(receiver,amount)) 0tez contract)
		| 	None -> failwith Errors.contractNotFound
		)
	|	Fa2 (address,id) ->
		(match (Tezos.get_entrypoint_opt "%transfer" address : FA2.transfer contract option) with
			Some contract ->
				Some (Tezos.transaction [{from_=sender;tx=[{to_=receiver;token_id=id;amount=amount}]}] 0tez contract)
		| 	None -> failwith Errors.contractNotFound
		)

let to_op_list (lst : operation option list) =
	List.fold_left (fun (acc,op) -> match (op : operation option) with (Some op) -> op::acc | None -> acc) [] lst
