
# distributed algorithms, n.dulay 2 feb 18
# coursework 2, paxos made moderately complex

defmodule Leader do

def start config, acceptors, replicas do
    bnum = {0, self()}
    active = false
    proposals = []
    spawn Scout, :start, [config, self(), acceptors, bnum]
    next config, acceptors, replicas, bnum, active, proposals
end # start

def next config, acceptors, replicas, bnum, active, proposals do
    receive do
        {:propose, s, c} ->
            proposals = 
                if s not in proposals do proposals ++ [s, c] else proposals 
                end
            if s not in proposals do 
                if active do
                    spawn Commander, :start, [config, self(), acceptors, replicas, {bnum, s, c}]
                end
            end
            next config, acceptors, replicas, bnum, active, proposals
        #{:adpopted, bnum, pvals} ->

        {:preempted, r, lamda} ->
            active = 
                if {r, lamda} > bnum do
                    false
                else
                    active
                end
            bnum = 
                if {r, lamda} > bnum do
                    {r+1, self()}
                else
                    bnum
                end
            if {r, lamda} > bnum do
                spawn Scout, :start, [config, self(), acceptors, bnum]
            end
            next config, acceptors, replicas, bnum, active, proposals
    end
    
end

def pmax pvals do
    for s <- pvals do
        get_max(nil, s, pvals, nil)
    end
end

def get_max bnum, s, pvals, c1 do
    if {b, s, c} == List.first(pvals) do
        {bnum, c1} =
            if b > bnum do
                {b, c}
            else 
                {bnum, c1}
            end
    end
    List.delete(pvals, 0)
    if length(pvals) > 0 do
        get_max bnum, s, pvals, c1
    else
        {bnum, s, c1}
    end

    
end

end # Server

