defmodule Commander do 
    def start config, commander_num, leader_pid, acceptors, replicas, {b, s, c} do
        config = Configuration.node_id(config, "Commander", commander_num)
        Debug.starting(config)
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
            Debug.letter(config,"Sending P2a message to acceptor #{inspect acceptor}")
            send acceptor, {:p2a,self(),parameters.pvalue}
        end

        next config, parameters
    end #start

    defp next config, params do
        receive do 
            {:p2b,acceptor,b} ->
                Debug.letter(config, "Received P2B message with ballot number #{b}  from acceptor #{inspect acceptor}.")
                if b == params.ballot_num do
                    Debug.letter(config, "Ballot Numbers Match. Appending to pvalues")
                    params= %{params | :waitfor => List.delete(params.waitfor, acceptor)  }
                    if length(params.waitfor) < length(params.acceptors)/2 do
                        Debug.letter(config, "Phase 2 sucessful. 
                                              Consensus achieved for slot number #{params.s}!")
                        for replica <- params.replicas do
                            send replica, {:decision, params.slot_num,
                                            params.command}
                        end
                    else
                        next config, params
                    end    
                else
                    Debug.letter(config, "Ballot number #{params.ballot_num} outdated. 
                                 Message was preempted.")
                    send params.leader_pid, {:preempted, b}
                end
        end
    end #next

end #Commander
