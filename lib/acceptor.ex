# Daryl Lim (dyl17) and Marian Lukac (ml11018)

defmodule Acceptor do

    def start config do
        # config = Configuration.node_id(config, "Acceptor", )
        next config, MapSet.new(), {-1, -1}
    end # start

    # main loop. Accepted contains all pvalues so far
    defp next config, accepted, ballot_num do
        receive do
            {:p1a, leader, b} ->
                Debug.letter(config, "[ACCEPTOR: #{inspect(self())}] Received p1a from leader #{inspect(leader)}, ballot: #{inspect b}")
                if Util.ballot_gt b, ballot_num do
                    ballot_num = b
                    send leader, {:p1b, self(), ballot_num, accepted}
                    next config, accepted, ballot_num
                else
                    send leader, {:p1b, self(), ballot_num, accepted}
                end

            # {ballot num, slot num, command}
            {:p2a, leader, {b, s, c}} ->
                Debug.letter(config, "[ACCEPTOR: #{inspect(self())}] Received p2a from leader #{inspect(leader)}, ballot: #{inspect(b)}")
                send leader, {:p2b,  self(), ballot_num}
                if b == ballot_num do
                    accepted = MapSet.put(accepted, {b, s, c})
                    next config, accepted, ballot_num
                end 
        end
        next config, accepted, ballot_num
    end # next
end # module