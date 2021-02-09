defmodule Leader do

    def start config, leader_num, acceptors, replicas do
        config = Configuration.node_id(config, "Leader", leader_num)
        Debug.starting(config)

        parameters = %{
            leader_num: leader_num,
            ballot_num: {0,leader_num},
            acceptors: acceptors,
            replicas: replicas,
            active: false,
            proposals: MapSet.new()
        }

        spawn Scout, :start, [ config, leader_num, self(), acceptors, parameters.ballot_num]

        next config, parameters 
    end

    defp next config, params do
        receive do
            {:propose, s, c} ->
                Debug.letter(config, "Proposal for slot #{s} containing command #{inspect c} accepted.")
                if !MapSet.member?(params.proposals, {s, c}) do
                      params = %{params | :proposals => MapSet.put(params.proposals,{s,c})}  
                      if params.active do
                        spawn Commander, :start, [config, params.leader_num, self(), 
                                                    params.acceptors, params.replicas, {params.ballot_num, s, c}]
                      end
                      next config, params
                end

            {:adopted, ballot_num, pvals} ->
                Debug.letter(config, "Proposals:  #{inspect params.proposals} updated with pvals: #{inspect pvals}.")
                params = %{params| :proposals => update_proposals(params.proposals, pvals) , :active => true}
                Debug.letter(config, "result: #{params.proposals}")
                for proposal <- params.proposals do
                    spawn Commander, :start, [config, params.leader_num, self(), 
                        params.acceptors, params.replicas, {ballot_num, Enum.at(proposal,0), Enum.at(proposal,1)}]
                end    
                next config, params

            {:preempted, {r,l}} ->
                if Util.ballot_gt({r,l},params.ballot_num) do
                    params = %{params | :active => false , :ballot_num => {r+1, params.leader_num}}
                    spawn Scout, :start, [ config, params.leader_num, self(), params.acceptors, params.ballot_num]
                    next config, params
                end
        end
        
        next config, params
    end #next

    defp update_proposals props, pvals do
        props_to_update= 
            pvals
            |> Enum.sort_by(fn {_b, s, _c} -> s end)
            |> Enum.chunk_by(fn {_b, s, _c} -> s end)
            |> Enum.map(fn lst -> Enum.max_by(lst, (fn {b,_s,_c} -> b end), Util.ballot_gt) end)
            |> MapSet.new(fn {_b,s,c}-> {s,c} end)
        
        slots = Enum.map(props_to_update) (fn {s,_c} -> s end) 
        proposals= for proposal <- props do
                        if !MapSet.member?(slots, Enum.at(proposal,0) )  do
                            proposal
                        end
                    end
        MapSet.union(props_to_update, proposals)
    end #update_proposals
end
