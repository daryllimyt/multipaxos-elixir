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
        {updated_slot_in, updated_requests, updated_proposals} = propose params, config
        next %{params | slot_in: updated_slot_in | requests: updated_requests | proposals: updated_proposals}, monitor
    end # next

    # Return updated params (slot_in, requests, decisions) to the main loop
    defp propose params, config do
        # While loop until no more commands in params.decisions
        if params.slot_in < params.slot_out + config.window_size and !:queue.is_empty(params.requests) do
            # isreconfig

            # if cannot find a matching slot_in in decisions then remove c from requests and move into proposals
            if !Enum.find(params.decisions, fn d -> 
                match?({^params.slot_in, _ }, d)
            end) do
                { { :value, c }, params.requests } = :queue.out(params.requests)
                params.proposals = MapSet.put(params.proposals, { params.slot_in, c })
                Enum.map(leaders, fn leader -> 
                    send leader, { :propose, params.slot_in, c} 
                end)
            end
            propose %{params | slot_in: params.slot_in + 1}, config
        else # Recursive base case
            {params.slot_in, params.requests, params.decisions}
        end
    end # propose

    defp check_decisions params, config do
        # while loop
        # 1. if there is a decision c1 corresponding to the current slot_out, check if already proposed some c2 for this slot
        # 2. if decision c1 exists, remove {slot_out, c2} from proposals
        # 3. if c1 != c2 then keep c2 in requests, propose later

        # if c1 exists in decisions. enum find returns nil if not found
        {_slot_out, c1} = Enum.find(params.decisions, fn d -> match?({params.slot_out, _ }, d) end)
        if c1 do
            # if the current slot_out already in proposals
            {_slot_out, c2} = Enum.find(params.proposals, fn p -> match?({params.slot_out, _ }, p) end)
            if c2 do
                params.proposals = MapSet.delete(params.proposals, {params.slot_out, c2})
                # Requeue for later proposal if mismatch
                if c1 != c2 do
                    params.requests = :queue.in(c2, params.requests)
                end
            end

            check_decisions %{params | slot_out: params.slot_out + 1}, config
        else
            {params.slot_out, params.requests, params.proposals}
        end

        # Execute the command
        perform c1, params, config
    end # check_decisions


    defp perform command, params, config do
        # check command has been performed, i.e. decision has been made on this command
        # {client_id, cid, op}
        if was_performed(command, params) do

        end

        # Apply operation only if new command
    end # propose

    defp was_performed command, params do
        # decisions -> {slot num, command}
        case decisions do
            # Match: 
            [{s, }| tail] -> s < params.slot_out or
            # No match
            [] ->
            # Base case
            [] ->
        end # case
    end # was_performed

end # modeule  