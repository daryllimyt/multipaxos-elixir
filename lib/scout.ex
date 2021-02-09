defmodule Scout do

    def start config, scout_num, leader_pid, acceptors, ballot_num  do 
        config = Configuration.node_id(config, "Scout", scout_num)
        Debug.starting(config)
        parameters = %{
            leader_pid: leader_pid,
            acceptors: acceptors,
            ballot_num: ballot_num,
            waitfor: acceptors,
            pvalues: []
        }
        
        for acceptor <- acceptors do
            Debug.letter(config,"Sending P1a message to acceptor #{inspect acceptor}")
            send acceptor, {:p1a,self(),parameters.ballot_num}
        end
        next config, parameters 
    end #start

    defp next config, params do
        receive do 
            {:p1b,acceptor,b,r} ->
                Debug.letter(config, "Received P1B message with ballot number #{b} 
                            and command #{inspect r} from acceptor #{inspect acceptor}.")
                if b == params.ballot_num do
                    Debug.letter(config, "Ballot Numbers Match. Appending to pvalues")
                    params= %{params | :pvalues => params.pvalues ++ [r] ,
                                       :waitfor => List.delete(params.waitfor, acceptor)  }
                    if length(params.waitfor) < length(params.acceptors)/2 do
                        Debug.letter(config, "Phase 1 sucessful. Current ballot number is #{b}!")
                         send params.leader_pid, {:adopted, params.ballot_num,
                                                  params.pvalues}
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

end #Scout
