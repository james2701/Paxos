
# distributed algorithms, n.dulay 2 feb 18
# coursework 2, paxos made moderately complex

defmodule Replica do


def start config, leaders do
    slot_in = 1
    slot_out = 1
    requests = []
    proposals =[]
    decisions = []
    next slot_in, slot_out, requests, proposals, decisions, leaders
end # start

defp next slot_in, slot_out, requests, proposals, decisions, leaders do
    {slot_out, requests, proposals, decisions} =
        receive do
            {:request, c} ->
                {slot_out, requests ++ c, proposals, decisions}
            {:decision, s, c} ->
                ndecisions = decisions ++ {s, c}
                {nslot_out, nrequests, nproposals} = decide slot_out, decisions, proposals, decisions
                {nslot_out, nrequests, nproposals, ndecisions}
        end
    {slot_in, nnrequests, nnproposals} = propose slot_in, slot_out, requests, proposals, decisions, leaders
    next slot_in, slot_out, nnrequests, nnproposals, decisions, leaders
end

defp propose slot_in, slot_out, requests, proposals, decisions, leaders do
    if slot_in < slot_out + 5 and length(requests) != 0 do
        c = List.first(requests)
        {requests, proposals}=
            if List.keymember?(decisions, slot_in, 0) do
                {requests, proposals}
            else
                {List.delete_at(requests, 0), proposals ++ [{slot_in, c}]}
            end
        if List.keymember?(decisions, slot_in, 0) do
            for lamda <- leaders do
                send lamda, {:propose, slot_in, c}
            end
        end
        slot_in = slot_in + 1
        propose slot_in, slot_out, requests, proposals, decisions, leaders
    else
        {slot_in, requests, proposals}
    end
end

defp perform {k, cid, op}, slot_out, decisions do
    {slist, _ } = Enum.unzip(decisions)
    if Enum.max(slist) < slot_out do
        slot_out + 1
    else
        slot_out = slot_out + 1
        send k, {:response, cid, op}
        slot_out
    end
end

defp decide slot_out, requests, proposals, decisions do
    
    if List.keymember?(decisions, slot_out, 0) do
        {requests, proposals} =
            if List.keymember?(proposals, slot_out, 0) do
                { _, cc } = List.keyfind(proposals, slot_out, 0)
                if List.keyfind(decisions, slot_out, 0) != List.keyfind(proposals, slot_out, 0) do
                    {requests ++ [cc], proposals -- [cc]}
                else
                    {requests, proposals -- [cc]}
                end
            else
                {requests, proposals}
            end
            slot_out = perform List.keyfind(decisions, slot_out, 0), slot_out, decisions
            decide slot_out, requests, proposals, decisions
    else 
        {slot_out, requests, proposals}
    end
end



end # Replica
