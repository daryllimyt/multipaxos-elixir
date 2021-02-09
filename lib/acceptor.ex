defmodule Acceptor do

    def start config do
        # config = Configuration.node_id(config, "Acceptor", )
        next config, MapSet.new(), -1
    end # start

    # main loop. Accepted contains all pvalues so far
    defp next config, accepted, ballot_num do
        receive do
            {:p1a, leader, b} ->
                Debug.letter(config, "[ACCEPTOR: #{inspect(self())}] Received p1a from leader #{inspect(leader)}, ballot: #{b}")
                if b > ballot_num do
                    ballot_num = b
                    send leader, {:p1b, self(), ballot_num, accepted}
                else
                    send leader, {:p1b, self(), ballot_num, accepted}
                end
            # {ballot num, slot num, command}
            {:p2a, leader, {b, s, c}} ->
                Debug.letter(config, "[ACCEPTOR: #{inspect(self())}] Received p2a from leader #{inspect(leader)}, ballot: #{b}")
                if b == ballot_num do
                    accepted = MapSet.put(accepted, {b, s, c})
                end
                send leader, {:p2b,  self(), ballot_num}
        end
        next ballot_num, accepted, ballot_num
    end # next
end # module