defmodule Commander do 
    def start config, leader_pid, acceptors, replicas, {b, s, c} do
        parameters = %{
            leader_pid: leader_pid,
            acceptors: acceptors,
            replicas: replicas,
            waitfor: acceptors,
            ballot_num: b,
            slot_num: s,
            command: c
        }

        for acceptor <- acceptors do
            Debug.letter(config,"[COMMANDER: #{config.node_num}] Sending P2a message to acceptor #{inspect acceptor}")
            send acceptor, {:p2a,self(), {b, s, c}}
        end

        next config, parameters
    end #start

    defp next config, params do
        receive do 
            {:p2b,acceptor,b} ->
                Debug.letter(config, "[COMMANDER: #{config.node_num}] Received P2B message with ballot number #{inspect b}  from acceptor #{inspect acceptor}.")
                if b == params.ballot_num do
                    Debug.letter(config, "[COMMANDER: #{config.node_num}] Ballot Numbers Match. Appending to pvalues")
                    params= %{params | :waitfor => List.delete(params.waitfor, acceptor)  }
                    if length(params.waitfor) < length(params.acceptors)/2 do
                        Debug.letter(config, " [COMMANDER: #{config.node_num}] Phase 2 sucessful. Consensus achieved for slot number #{params.slot_num}!")
                        for replica <- params.replicas do
                            Debug.letter(config,"[COMMANDER: #{config.node_num}] Send decision for slot #{params.slot_num} with command #{inspect params.command} to replica #{inspect replica}")
                            send replica, {:decision, params.slot_num,
                                            params.command}
                        end
                    else
                        next config, params
                    end    
                else
                    Debug.letter(config, "[COMMANDER: #{config.node_num}] Ballot number #{inspect params.ballot_num} outdated. Message was preempted.")
                    send params.leader_pid, {:preempted, b}
                end
        end
        send config.monitor, { :COMMANDER_FINISHED, config.node_num } 
    end #next

end #Commander
