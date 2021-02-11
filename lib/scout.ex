defmodule Scout do

    def start config, leader_pid, acceptors, ballot_num  do 
        parameters = %{
            leader_pid: leader_pid,
            acceptors: acceptors,
            ballot_num: ballot_num,
            waitfor: acceptors,
            pvalues: []
        }
         
        for acceptor <- acceptors do
            Debug.letter(config,"[SCOUT: #{config.node_num}] Sending P1a message to acceptor #{inspect acceptor}")
            send acceptor, {:p1a,self(),parameters.ballot_num}
        end
        next config, parameters 
    end #start

    defp next config, params do
        receive do 
            {:p1b,acceptor,b,r} ->
                Debug.letter(config, "[SCOUT: #{config.node_num}] Received P1B message with ballot number #{inspect b} and command #{inspect r} from acceptor #{inspect acceptor}.")
                if b == params.ballot_num do
                    Debug.letter(config, "[SCOUT: #{config.node_num}] Ballot Numbers Match. Appending to pvalues")
                    params= %{params | :pvalues => params.pvalues ++ MapSet.to_list(r) ,
                                       :waitfor => List.delete(params.waitfor, acceptor)  }
                    if length(params.waitfor) < length(params.acceptors)/2 do
                        Debug.letter(config, "[SCOUT: #{config.node_num}] Phase 1 sucessful. Current ballot number is #{inspect b}!")
                        send params.leader_pid, {:adopted, params.ballot_num,
                                                  params.pvalues}
                    else
                        next config, params
                    end    
                else
                    Debug.letter(config, "[SCOUT: #{config.node_num}] Ballot number #{inspect params.ballot_num} outdated. Message was preempted.")
                    send params.leader_pid, {:preempted, b}
                end
        end
        send config.monitor, { :SCOUT_FINISHED, config.node_num } 
    end #next

end #Scout
