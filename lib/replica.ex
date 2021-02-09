def module Replica do

    # A replica runs in an infinite loop, receiving messages. 
    # Replicas receive two kinds of messages: requests and decisions. 
    # When it receives a request for command c from a client, 
    # the replica adds the request to set requests.

    # Interfaces between client <-> DB, leaders

    def start config, database, monitor do
        receive do
            { :BIND, leaders } ->
                params = %{
                    state: database,
                    slot_in: 1,
                    slot_out: 1,
                    requests: :queue.new(), # either erlang queue or list (linkedlist)
                    decisions: MapSet.new(),
                    proposals: MapSet.new(),
                    leaders: leaders # need to obtain this from
                }
                next params, monitor
        end
    end # start

    # Main loop
    # c = {client_id, command id, operation}
    # s = slot number
    defp next params, monitor do
        receive do
            
            { :CLIENT_REQUEST, c } -> 
                # propse command c for lowest unused slot
                params.requests = :queue.in(c, params.requests)
            { :decision, s, c} ->
                params.decisions = MapSet.put(params.decisions, {s,c})
                # Another while loop here: consider which decisions are ready for execution before checking for msgs
                check_decisions params, config
            
        end
        {slot_in, requests, proposals} = propose params, config
        next %{params | slot_in: slot_in | requests: requests | proposals: proposals}, monitor
    end # next

    # Return updated params (slot_in, requests, decisions) to the main loop
    defp propose params, config do
        # While loop until no more commands in params.decisions
        if params.slot_in < params.slot_out + config.window_size and !:queue.is_empty(params.requests) do
            # isreconfig

            # if cannot find a matching slot_in in decisions then remove c from requests and move into proposals
            if not Enum.any?(params.decision, fn { s, _c } -> s == params.slot_in end) do
                { { :value, c }, params.requests } = :queue.out(params.requests)
                params.proposals = MapSet.put(params.proposals, { params.slot_in, c })
                for leader <- params.leaders, do: send leader, { :propose, params.slot_in, c} 
            end
            propose %{params | slot_in: params.slot_in + 1}, config
        else
            {params.slot_in, params.requests, params.decisions}
        end
    end # propose

    defp check_decisions params, config do
        # while loop
        # 1. if there is a decision c1 corresponding to the current slot_out, check if already proposed some c2 for this slot
        # 2. if decision c1 exists, remove {slot_out, c2} from proposals
        # 3. if c1 != c2 then keep c2 in requests, propose later

        # if c1 exists in decisions. enum find returns nil if not found
        candidate_1 = Enum.find(params.decisions, fn { s, _c } -> s == params.slot_out end)
        if candidate_1 do
            { _s, command_1 } = candidate_1
            # if the current slot_out already in proposals
            candidate_2 = Enum.find(params.proposals, fn { s, _c } -> s == params.slot_out end)
            if candidate_2 do
                { _s, command_2 } = candidate_2
                params.proposals = MapSet.delete(params.proposals, {params.slot_out, command_2})
                # Requeue for later proposal if mismatch
                if command_1 != command_2 do
                    params.requests = :queue.in(command_2, params.requests)
                end
            end

            check_decisions %{params | slot_out: params.slot_out + 1}, config
        else
            {params.slot_out, params.requests, params.proposals}
        end

        # Execute the command
        perform candidate_1, params, config
    end # check_decisions


    defp perform command, params, config do
        # check command has been performed, i.e. decision has been made on this command
        found = Enum.find(params.decisions, fn d -> match?({params.slot_out, command }, d) end)
        if !found do
            {client, cid, op} = command
            send params.state { :EXECUTE, op }
            send client { :CLIENT_REPLY, cid, :result }
        end
    end # perform

    # # Loop over decisions (pass in as list)
    # defp was_performed command, decisions do
    #     # decisions -> {slot num, command}
    #     case decisions do
    #         # Match: 
    #         [{s, command}| tail] -> s < params.slot_out or was_performed command, tail
    #         # No match
    #         [_ | tail] -> was_performed comamnd, tail
    #         # Base case
    #         [] -> false
    #     end # case
    # end # was_performed

end # modeule  