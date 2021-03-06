
Phonon definitions

### Disperion relation
function Ïğ(k)
    return tğ*abs(sin(k*a1))
end
Ïğ(10)

### Definition of Bare D_0, Dzerobar, and D_zero_K
function Dâá´¿(k,t1,t2)
    if t1>t2
        return (-(1)*sin(Ïğ(k)*(t1-t2)*h))/(Ïğ(k))     # the equal to case shall give 0
    else
        return 0
    end
end

Dâá´¿(10,1,2)
-sin(Ïğ(10)*h)/Ïğ(10)


function DÌâá´¿(k,t1,t2)
    if t1>=t2                            ### What does DÌ do at equal times? produce 1? What if it rigorously doesn't hold?
        return (-1*cos(Ïğ(k)*(t1-t2)*h))
    else
        return 0
    end                     #remember this is only true if t1>t2
end

DÌâá´¿(10,1,1)
cos(Ïğ(10)*h)


function Dâá´·(k,t,t1,Tphonon)
    a= (-im)*(cos(Ïğ(k)*(t-t1)*h) * coth(Ïğ(k)*0.5/(Tphonon)) )* (1/Ïğ(k))
    return a
end

Dâá´·(10,2,1,1)

function DÌâá´·(k,t,t1,Tphonon)
    return im*sin(Ïğ(k)*(t-t1)*h)*coth(Ïğ(k)*0.5/(Tphonon))
end

DÌâá´·(1,2,1,1)

#%%
Electron Definitions

function Ïµâ(k)
    return tâ*(1-cos(k*a1))
end


function Gâá´¿(k,t1,t2)
    if t1>=t2
        return -im*exp(-im*Ïµâ(k)*(t1-t2)*h)
    else
        return 0
    end
end

Gâá´¿(10,1e4,1e4) #prints 0 for t1<t2

function Gâá´·(k,t1,t2,Telectron,Î¼)
    return -im*tanh((Ïµâ(k)-Î¼)/(2*Telectron))*exp(-im*Ïµ(k)*(t1-t2)*h)
end
