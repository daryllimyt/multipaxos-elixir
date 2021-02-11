defmodule Leader do

    def start config, leader_num  do
        receive do
            {:BIND, acceptors, replicas} ->
                    parameters = %{
                        ballot_num: {0,leader_num},
                        acceptors: acceptors,
                        replicas: replicas,
                        active: false,
                        proposals: MapSet.new()
                    }
                    send config.monitor, { :SCOUT_SPAWNED, config.node_num }
                    spawn Scout, :start, [ config, self(), acceptors, parameters.ballot_num]
                    next config, parameters 
        end
    end

    defp next config, params do
        receive do
            {:propose, s, c} ->
                Debug.letter(config, "[LEADER: #{config.node_num}] Proposal for slot #{s} containing command #{inspect c} accepted.")
                if !MapSet.member?(params.proposals, {s, c}) do
                      params = %{params | :proposals => MapSet.put(params.proposals,{s,c})}  
                      if params.active do
                        send config.monitor, { :COMMANDER_SPAWNED, config.node_num }
                        spawn Commander, :start, [config, self(), 
                                                    params.acceptors, params.replicas, {params.ballot_num, s, c}]
                      end
                      next config, params
                end

            {:adopted, ballot_num, pvals} ->
                Debug.letter(config, "[LEADER: #{config.node_num}] Proposals:  #{inspect params.proposals} updated with pvals: #{inspect pvals}.")
                params = %{params| :proposals => update_proposals(params.proposals, pvals) , :active => true}
                Debug.letter(config, "[LEADER: #{config.node_num}] result: #{inspect params.proposals}")
                for proposal <- params.proposals do
                    {s, c} = proposal
                    send config.monitor, { :COMMANDER_SPAWNED, config.node_num }
                    spawn Commander, :start, [config, self(), 
                        params.acceptors, params.replicas, {ballot_num, s, c}]
                end    
                next config, params

            {:preempted, {r,l}} ->
                if Util.ballot_gt({r,l},params.ballot_num) do
                    params = %{params | :active => false , :ballot_num => {r+1, config.node_num}}
                    send config.monitor, { :SCOUT_SPAWNED, config.node_num }
                    spawn Scout, :start, [ config, self(), params.acceptors, params.ballot_num]
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
            |> Enum.map(fn lst -> Enum.max_by(lst, (fn {b,_s,_c} -> b end), &Util.ballot_gt/2) end)
            |> MapSet.new(fn {_b,s,c}-> {s,c} end)
        
        slots = props_to_update
                |> MapSet.to_list()
                |> Enum.map(fn {s,_c} -> s end) 
                |> MapSet.new()
                
        props_to_keep= props
                   |> MapSet.to_list()
                   |> Enum.filter(fn {s,_c} -> !MapSet.member?(slots,s) end)
                   |>MapSet.new()

        MapSet.union(props_to_update, props_to_keep)
    end #update_proposals
end
