
# distributed algorithms, n.dulay 2 feb 18
# coursework 2, paxos made moderately complex

defmodule Leader do

def start config do
    bnum = {0, self()}
    active = false
    proposals = []
    {acceptors, replicas} =
        receive do
            { :bind, acceptors, replicas } -> {acceptors, replicas}
        end
    spawn Scout, :start, [config, self(), acceptors, bnum]
    next config, acceptors, replicas, bnum, active, proposals
end # start

def next config, acceptors, replicas, bnum, active, proposals do
    receive do
        {:propose, s, c} ->
            proposals = 
                if List.keymember?(proposals, s, 0) do proposals ++ [s, c] else proposals 
                end
            if List.keymember?(proposals, s, 0) do 
                if active do
                    spawn Commander, :start, [config, self(), acceptors, replicas, {bnum, s, c}]
                end
            end
            next config, acceptors, replicas, bnum, active, proposals
        {:adpopted, bnum, pvals} ->        
            y = pmax {}, pvals
            proposals = update proposals, y
            for {s, c} <- proposals do
                spawn(Commander, :start, [config, self(), acceptors, replicas, {bnum, s, c}])
            end
            active = true
            next config, acceptors, replicas, bnum, active, proposals
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

defp pmax mylist, pvals do
    if length(pvals) == 0 do
        {_blist, slist, clist} = DAC.unzip3(mylist)
        List.zip([slist, clist])
    else
        {b, s, c} = List.first(pvals)
        mylist =
            unless List.keymember?(mylist, s, 1) do
                mylist ++ {b, s, c}
            else mylist end
        if List.keymember?(mylist, s, 1) do
            {b1, _s1, _c1} = List.keyfind(mylist, s, 1)
            if b > b1 do
                List.keyreplace(mylist, s, 1, {b, s, c})
            end
        end
        pvals = List.delete_at(pvals, 0)
        pmax mylist, pvals
    end
end

defp update x, y do
    if length(y) == 0 do
        x
    else
        x =
            if List.first(y) in x do
                x
            else
                x ++ List.first(y)
            end
        y = List.delete_at(y, 0)
        update x, y
    end
end

end # Server

