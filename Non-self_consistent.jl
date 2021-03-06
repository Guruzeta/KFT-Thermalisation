using  Debugger


######### Model/simulation parameters
t๐=2 #phonon bandwidth
tโ=1 #electron bandwidth= = ฯ
a1=1  #lattice constant
ฮป๐= 1 #phonon-electron coupling
Tโ=0.75# electron temperature
T๐=1.75# phonon temperature
ฮผ = -1  # chemical potential of the electron


#time-simulation parameters
h= 0.08 #the time spacing
Time_max = 50 #the net time
N๐ก= Int64(Time_max/h) #


#phonon volume parameters
sitenum = 4 #gives the no. of sites in the lattice
a2=2*ฯ*(1/(sitenum*a1)) #reciprocal space lattice constant
V_ph = collect(-0.5*sitenum*a2:a2:0.5*a2*(sitenum+1))
#filter!(e->e!=0,V_ph) # not taking k=0 mode currently


#%%

#Phonon definitions

### Disperion relation
function ฯ๐(k)
    return t๐*abs(sin(V_ph[k]*a1*0.5))+0.2
end


### Definition of Bare D_0, Dzerobar, and D_zero_K
function Dโแดฟ(k,t1,t2)
    if t1>t2
        return (-(1)*sin(ฯ๐(k)*(t1-t2)*h))/(ฯ๐(k))     # the equal to case shall give 0
    else
        return 0
    end
end





function Dฬโแดฟ(k,t1,t2)
    if t1>=t2                            ### What does Dฬ do at equal times? produce 1? What if it rigorously doesn't hold?
        return (-1*cos(ฯ๐(k)*(t1-t2)*h))
    else
        return 0
    end                     #remember this is only true if t1>t2
end


function Dโแดท(k,t,t1,Tphonon)
    a= (-im)*(cos(ฯ๐(k)*(t-t1)*h) * coth(ฯ๐(k)*0.5/(Tphonon)) )* (1/ฯ๐(k))
    return a
end

Dโแดท(1,2,1,T๐)

function Dฬโแดท(k,t,t1,Tphonon)
    return im*sin(ฯ๐(k)*(t-t1)*h)*coth(ฯ๐(k)*0.5/(Tphonon))
end



#%%

# Electron Definitions

function ฯตโ(k)
    return tโ*(1-cos(V_ph[k]*a1))+0.2
end


function Gโแดฟ(k,t1,t2)
    if t1>=t2
        return -im*exp(-im*ฯตโ(k)*(t1-t2)*h)
    else
        return 0
    end
end

    #prints 0 for t1<t2

function Gโแดท(k,t1,t2,Telectron,ฮผ)

    return -im*tanh((ฯตโ(k)-ฮผ)/(2*Telectron))*exp(-im*ฯตโ(k)*(t1-t2)*h)
end



Gโแดท(1,2,3,4,5)


#%%
#Matrix definitions: making Array of arrays : each inner array is 2dim with currently undefine size, the outer array is 1d and holds
#total k points+ 10 elements


    Dแดฟmatrix = Array{Array{ComplexF64,2},1}(undef,length(V_ph)+2)

    Dฬแดฟmatrix = Array{Array{ComplexF64,2},1}(undef,length(V_ph)+2)

    Dแดทmatrix = Array{Array{ComplexF64,2},1}(undef,length(V_ph)+2)

    Dฬแดทmatrix = Array{Array{ComplexF64,2},1}(undef,length(V_ph)+2)

    Gแดฟmatrix = Array{Array{ComplexF64,2},1}(undef,length(V_ph)+2)

    Gแดทmatrix = Array{Array{ComplexF64,2},1}(undef,length(V_ph)+2)

    ฮฃ๐แดฟ= Array{Array{ComplexF64,2},1}(undef,length(V_ph)+2)

    ฮฃ๐แดท = Array{Array{ComplexF64,2},1}(undef,length(V_ph)+2)

    ฮฃโแดฟ = Array{Array{ComplexF64,2},1}(undef,length(V_ph)+2)

    ฮฃโแดท = Array{Array{ComplexF64,2},1}(undef,length(V_ph)+2)

matinit = function ()
    for i=1:length(V_ph)+2
        Dแดฟmatrix[i] = Array{ComplexF64,2}(undef,N๐ก+5,N๐ก+5)
        Dฬแดฟmatrix[i] = Array{ComplexF64,2}(undef,N๐ก+5,N๐ก+5)
        Dแดทmatrix[i] = Array{ComplexF64,2}(undef,N๐ก+5,N๐ก+5)
        Dฬแดทmatrix[i] = Array{ComplexF64,2}(undef,N๐ก+5,N๐ก+5)
        Gแดฟmatrix[i] = Array{ComplexF64,2}(undef,N๐ก+5,N๐ก+5)
        Gแดทmatrix[i] = Array{ComplexF64,2}(undef,N๐ก+5,N๐ก+5)
        ฮฃ๐แดฟ[i] = Array{ComplexF64,2}(undef,N๐ก+5,N๐ก+5)
        ฮฃ๐แดท[i] = Array{ComplexF64,2}(undef,N๐ก+5,N๐ก+5)
        ฮฃโแดฟ[i] = Array{ComplexF64,2}(undef,N๐ก+5,N๐ก+5)
        ฮฃโแดท[i] = Array{ComplexF64,2}(undef,N๐ก+5,N๐ก+5)
    end
end
matinit()




##%

### DEFINITIONS OF CONVOLUTION FUNCTIONS

# Definitions of convolutions for phonons

function F(k,tโ,tโ)
    if tโ>tโ
        return sum(t->ฮฃ๐แดฟ[k][tโ,t]*Dแดฟmatrix[k][t,tโ]*h, collect(tโ:tโ))
    elseif tโ==tโ
        return 0
    else
        return "You're convoluting in the opposite direction. Possible error at RR conv"
    end
end


F(3,9,10)

function RK(k,t1,t2) #โซโแต ฮฃ๐แดฟโDแดท
    if t1>1
        return sum(t->ฮฃ๐แดฟ[k][t1,t]*Dแดทmatrix[k][t,t2]*h, collect(1:t1))
    else
        return 0
    end
end

RK(2,2,3)

function KA(k,t1,t2) #โซโโDแดฟ
    if t2>1
        return sum(t->ฮฃ๐แดท[k][t1,t]*Dแดฟmatrix[k][t2,t] * h, collect(1:t2)) ## Dแดฌ is just transpose of Dแดฟ
    else
        return 0
    end
end
KA(2,3,2)

###### Equivalent definitions of convolutions for electrons ###########

function Fโ(k,tโ,tโ)
    if tโ>tโ
        return sum(t->ฮฃโแดฟ[k][tโ,t]*Gแดฟmatrix[k][t,tโ]*h, collect(tโ:tโ))
    elseif tโ==tโ
        return 0
    else
        return "You're convoluting in the opposite direction. Possible error at RR/electron conv"
    end
end

function RKโ(k,t1,t2) #โซโแต ฮฃโแดฟโDแดท
    if t1>1
        return sum(t->ฮฃโแดฟ[k][t1,t]*Gแดทmatrix[k][t,t2]*h, collect(1:t1))
    else
        return 0
    end
end


RK(2,2,3)

function KAโ(k,t1,t2) #โซโโDแดฟ
    if t2>1
        return sum(t->ฮฃโแดท[k][t1,t]*conj(Gแดฟmatrix[k][t2,t] )*h, collect(1:t2))
    else
        return 0
    end
end


function sumBZ1d(k,p) # returns the index of element in the BZ array that reflects the physical sum of two input indices, taking the periodic behaviour into account
    if V_ph[k]*V_ph[p] ==(ฯ/a1)^2
        return p

    elseif -1*ฯ/a1<=V_ph[k]+V_ph[p]<=ฯ/a1
        res = V_ph[k]+V_ph[p]
        return findmin(abs.(V_ph.-res))[2]

    elseif V_ph[k]+V_ph[p]>ฯ/a1
        res = V_ph[k]+V_ph[p]-2*ฯ/a1
        return findmin(abs.(V_ph.-res))[2]

    else V_ph[k]+V_ph[p]<-1*ฯ/a1
        res = V_ph[k]+V_ph[p]+2*ฯ/a1
        return findmin(abs.(V_ph.-res))[2]
    end
end


function negative(k) # returns array index of -k vector
    middle = (length(V_ph)+1)*0.5
    l=length(V_ph)
    return Int((k<middle)*(l-k+1) + (k==middle)*middle+ (k>middle)*(middle-(k-middle)))
end

negative(4)


# lesson - .$ where $ is a  binary operation is the julia equivalent of handling doing array +-* with a scalar on each element
sumBZ1d(1,6) #probably need to define zero mode




#%%

### INITIALIZATIONS


######### diagonal Initialization ##########
boxinitindex=20

boxinit=function()

    for k =1:length(V_ph)
        for i=1:N๐ก
            Dแดฟmatrix[k][i,i]=0 #exactly 0
            Dฬแดฟmatrix[k][i,i]=-1 #exactly 1
            Gแดฟmatrix[k][i,i] = -im #exactly true           ## Gr(t,t)โฬธ0
            ##Dแดทmatrix[k][i,i] =1                   ### Why am I initializing the DK?

            ##Gแดทmatrix[k][i,i] = Gโแดท(k,t,t,Tโ,ฮผ)      ### Why am I even initializing this? Aren't we supposed to get this from the code?

            ##Dแดฟmatrix[k][i+1,i] = Dโแดฟ(k,i+1,i) #only 2,1 or all i+1,i???
            ##Dฬแดฟmatrix[k][i+1,i] = Dฬโแดฟ(k,+i,i)
            ##ฮฃ๐แดฟ[k][i+1,i] =
        end
        #println(k)
    end



    ######## Box Initialization ############

    #GF Initialization

    for k=1:length(V_ph)
        for i=1:boxinitindex
            for j=1:boxinitindex
                Dแดฟmatrix[k][i,j] = Dโแดฟ(k,i,j)
                Dฬแดฟmatrix[k][i,j] = Dฬโแดฟ(k,i,j)
                Dแดทmatrix[k][i,j] = Dโแดท(k,i,j,T๐)
                Dฬแดทmatrix[k][i,j] = Dฬโแดท(k,i,j,T๐)
                Gแดฟmatrix[k][i,j] = Gโแดฟ(k,i,j)
                Gแดทmatrix[k][i,j] =  Gโแดท(k,i,j,Tโ,ฮผ)

            end
        end
    end
end







        # Dแดฟmatrix[k][2,1] = Dโแดฟ(k,2,1) #lower traingular
        # Dฬแดฟmatrix[k][2,1] = Dฬโแดฟ(k,2,1) #lower triangular
        #
        # Dแดทmatrix[k][1,1] = Dโแดท(k,1,1,T๐)
        # Dแดทmatrix[k][1,2] = Dโแดท(k,1,2,T๐)
        # Dแดทmatrix[k][2,1] = Dโแดท(k,2,1,T๐)
        # Dแดทmatrix[k][2,2] = Dโแดท(k,2,2,T๐)
        #
        # Dฬแดทmatrix[k][1,1] = Dฬโแดท(k,1,1,T๐)
        # Dฬแดทmatrix[k][1,2] = Dฬโแดท(k,1,2,T๐)
        # Dฬแดทmatrix[k][2,1] = Dฬโแดท(k,2,1,T๐)
        # Dฬแดทmatrix[k][2,2] = Dฬโแดท(k,2,2,T๐)
        #
        # Gแดฟmatrix[k][2,1] = Gโแดฟ(k,2,1)
        #
        # Gแดทmatrix[k][1,1] =  Gโแดท(k,1,1,Tโ,ฮผ)
        # Gแดทmatrix[k][1,2] =  Gโแดท(k,1,2,Tโ,ฮผ)
        # Gแดทmatrix[k][2,1] =  Gโแดท(k,2,1,Tโ,ฮผ)
        # Gแดทmatrix[k][2,2] =  Gโแดท(k,2,2,Tโ,ฮผ)

boxinit()


#Self energy Initialization


#%%
Dแดฟmatrix
matinit()
boxinit()
#Actual for loop
testrange=100
for i=boxinitindex:test       ### The diagonal value #should probably start from 2

    #Update DR
    for k=1:length(V_ph)
        for j=1:i

            if j<i
                Dฬแดฟmatrix[k][i,j] = ฯ๐(k)^2 * Dโแดฟ(k,i,i-1) * Dแดฟmatrix[k][i-1,j] - Dฬโแดฟ(k,i,i-1) * Dฬแดฟmatrix[k][i-1,j] + (h/2)*( Dฬโแดฟ(k,i,i)* F(k,i,j) + Dฬโแดฟ(k,i,i-1) * F(k,i-1,j) )
            end
            @bp
            Dแดฟmatrix[k][i+1,j] = Dฬโแดฟ(k,i+1,i) * Dแดฟmatrix[k][i,j] + Dโแดฟ(k,i+1,i) * Dฬแดฟmatrix[k][i,j] + (h/2)*Dโแดฟ(k,i+1,i)*F(k,i,j)
        end
    end

     #Update DK
     for k = 1:length(V_ph)
         for j=1:i
             Dฬแดทmatrix[k][i,j] = ฯ๐(k)^2 * Dโแดฟ(k,i,i-1) * Dแดทmatrix[k][i-1,j] - Dฬโแดฟ(k,i,i-1) * Dฬแดทmatrix[k][i-1,j] + (h/2)*(  Dฬโแดฟ(k,i,i)* RK(k,i,j) + Dฬโแดฟ(k,i,i-1)* RK(k,i-1,j) + Dฬโแดฟ(k,i,i)* KA(k,i,j) + Dฬโแดฟ(k,i,i-1)* KA(k,i-1,j) )
             Dแดทmatrix[k][i+1,j] = Dฬโแดฟ(k,i+1,i) * Dแดทmatrix[k][i,j] + Dโแดฟ(k,i+1,i) * Dฬแดทmatrix[k][i,j] + (h/2)*( Dโแดฟ(k,i+1,i)* RK(k,i,j) + Dโแดฟ(k,i+1,i)* KA(k,i,j) )
             Dแดทmatrix[k][j,i+1] = -conj(Dแดทmatrix[k][i+1,j])
             Dฬแดทmatrix[k][j,i] = +conj(Dฬแดทmatrix[k][i,j])#what abt i,i entry? If Dk is imaginary, then it will just flip sign here.....? This term is to take care of that...Not sure
         end
     end

    # Update GR, GK
    for k = 1 : length(V_ph)
        for j=1:i
            Gแดฟmatrix[k][i+1,j] = im*Gโแดฟ(k,i+1,i)*Gแดฟmatrix[k][i,j] + (h/2)* Gโแดฟ(k,i+1,i)*(Fโ(k,i,j))
            Gแดทmatrix[k][i+1,j] = im*Gโแดฟ(k,i+1,i)*Gแดทmatrix[k][i,j]+ (h/2)*Gโแดฟ(k,i+1,i)* (RKโ(k,i,j) + KAโ(k,i,j))
            Gแดทmatrix[k][j,i+1] = - conj(Gแดทmatrix[k][i+1,j]) # iGแดท is hermitian  โน iGแดท(1,2) = conj((iGแดท(2,1)) โน Gแดท(1,2) = - conj(Gแดท(2,1))
        end
    end


    # Extract Phonon self energy ฮฃ๐แดท,ฮฃ๐แดฟ in the n+1,n+1 block (use in Dr calculation in next loop)
    # ฮฃ๐แดฟ update
    for j=1:i
        for k=1:length(V_ph)
            sum=0
            for p=1:length(V_ph)
                sum = sum -im*(ฮป๐^2/2)*(Gแดฟmatrix[sumBZ1d(k,p)][i+1,j]*Gแดทmatrix[p][j,i+1] + Gแดทmatrix[sumBZ1d(k,p)][i+1,j]* conj(Gแดฟmatrix[p][i+1,j]) )
            end
            ฮฃ๐แดฟ[k][i+1,j]=sum
            sum=nothing
        end
    end

    # ฮฃ๐แดท Update
    for j=1:i
        for k=1:length(V_ph)
            sum1=0
            sum2=0
            for p=1:length(V_ph)
                ### Code for lower edge
                sum1 = sum1 - im*(ฮป๐^2/2)*( Gแดฟmatrix[sumBZ1d(k,p)][i+1,j]*conj(Gแดฟmatrix[p][i+1,j]) - Gแดทmatrix[sumBZ1d(k,p)][i+1,j]*conj(Gแดทmatrix[p][i+1,j])  )

                ### Code for upper edge
                sum2 = sum2- im*(ฮป๐^2/2)*( conj(Gแดฟmatrix[sumBZ1d(k,p)][i+1,j])*Gแดฟmatrix[p][i+1,j] - Gแดทmatrix[sumBZ1d(k,p)][j,i+1]*conj(Gแดทmatrix[p][j,i+1]) )
            end
            ฮฃ๐แดท[k][i+1,j]= sum1
            ฮฃ๐แดท[k][j,i+1]= sum2
            sum1=nothing
            sum2=nothing
        end
    end

    #Now extract self energies ฮฃโแดฟ,ฮฃโแดท in the n+1,n+1 block (shall be used for calculation of GR in n+2,n+2 loop i.e. next big loop's GR,GK update since you're dropping the self consistent term)

    ## ฮฃโแดฟ Update
    for j=1:i
        for k=1:length(V_ph)
            sum=0
            for p=1:length(V_ph)
                sum = sum + im*( ฮป๐^2/2 )*( Gแดฟmatrix[sumBZ1d(k,p)][i+1,j] * Dแดทmatrix[negative(p)][i+1,j] + Gแดทmatrix[sumBZ1d(k,p)][i+1,j] * Dแดฟmatrix[negative(p)][i+1,j] )
            end
            ฮฃโแดฟ[k][i+1,j]= sum
            sum=nothing
        end
    end

    ## ฮฃโแดท Update
    for j=1:i
        for k=1:length(V_ph)
            sum1=0
            sum2=0
            for p=1:length(V_ph)
                ## code for upper edges
                sum1 = sum1+im*(ฮป๐^2/2)*( Gแดฟmatrix[sumBZ1d(k,p)][i+1,j] * Dแดฟmatrix[negative(p)][i+1,j] + Gแดทmatrix[sumBZ1d(k,p)][i+1,j] * Dแดทmatrix[negative(p)][i+1,j]  )

                ## code for lower edges
                sum2 = sum2+ im*(ฮป๐^2/2)*( conj( Gแดฟmatrix[sumBZ1d(k,p)][i+1,j] )* Dแดฟmatrix[p][i+1,j] - conj( Gแดทmatrix[sumBZ1d(k,p)][i+1,j] ) * Dแดทmatrix[p][i+1,j] )
            end
            ฮฃโแดท[k][i+1,j]=sum1
            ฮฃโแดท[k][j,i+1]=sum2
            sum1=nothing
            sum2=nothing
        end
    end

    ############## Diagonal terms update #############


    #Update GK(t+ฯต,t+ฯต) i.e GK(i+1,i+1) here  - needs ฮฃโแดฟ on the i+1 block edges  i.e.
    for k=1:length(V_ph)
        Gแดทmatrix[k][i+1,i+1] = im*Gโแดฟ(k,i+1,i)*Gแดทmatrix[k][i,i+1]+ (h/2)*Gโแดฟ(k,i+1,i)* (RKโ(k,i,i+1) + KAโ(k,i,i+1))
    end
    #initialie Gr(i+1,i+1) = -im from before i.e. outside this loop

    #updating ฮฃ๐แดฟ[i+1,i+1],ฮฃ๐แดท[i+1,i+1]
    for k=1:length(V_ph)
        sum=0
        for p=1:length(V_ph)
            sum = sum -im*(ฮป๐^2/2)*( Gแดฟmatrix[sumBZ1d(k,p)][i+1,i+1]*Gแดทmatrix[p][i+1,i+1] + Gแดทmatrix[sumBZ1d(k,p)][i+1,i+1]* conj(Gแดฟmatrix[p][i+1,i+1]) )
        end
        ฮฃ๐แดฟ[k][i+1,i+1]=sum
        sum=nothing
    end
    #- this will be used to update the DR[i+1,i+1]

    #updating ฮฃ๐แดท(i+1,i+1)
    for k=1:length(V_ph)
        sum=0
        for p=1:length(V_ph)
            sum = sum - im*(ฮป๐^2/2)*( Gแดฟmatrix[sumBZ1d(k,p)][i+1,i+1]*conj(Gแดฟmatrix[p][i+1,i+1]) - Gแดทmatrix[sumBZ1d(k,p)][i+1,i+1]*conj(Gแดทmatrix[p][i+1,i+1])  )
        end
        ฮฃ๐แดท[k][i+1,i+1] = sum
        sum=nothing
    end


    #Update DK(t+ฯต,t+ฯต) here, Dฬ(i,i) block is calculated already
    for k=1:length(V_ph)
        Dฬแดทmatrix[k][i+1,i] = ฯ๐(k)^2 * Dโแดฟ(k,i+1,i) * Dแดทmatrix[k][i,i] - Dฬโแดฟ(k,i+1,i) * Dฬแดทmatrix[k][i,i] + (h/2)*(  Dฬโแดฟ(k,i+1,i+1)* RK(k,i+1,i) + Dฬโแดฟ(k,i+1,i)* RK(k,i,i) + Dฬโแดฟ(k,i+1,i+1)* KA(k,i+1,i) + Dฬโแดฟ(k,i+1,i)* KA(k,i,i) )
        Dฬแดทmatrix[k][i,i+1] = conj( Dฬแดทmatrix[k][i+1,i] )
        Dแดทmatrix[k][i+1,i+1] = Dฬโแดฟ(k,i+1,i) * Dแดทmatrix[k][i,i+1] + Dโแดฟ(k,i+1,i) * Dฬแดทmatrix[k][i,i+1] + (h/2)*( Dโแดฟ(k,i+1,i)* RK(k,i,i+1) + Dโแดฟ(k,i+1,i)* KA(k,i,i+1) )
    end

    #updating sigmElR, sigmaElK here (given that now you've all Gfuncs at the i+1,i+1)
    for k=1:length(V_ph)
        sum=0
        for p=1:length(V_ph)
            sum = sum + im*( ฮป๐^2/2 )*( Gแดฟmatrix[sumBZ1d(k,p)][i+1,i+1] * Dแดทmatrix[negative(p)][i+1,i+1] + Gแดทmatrix[sumBZ1d(k,p)][i+1,i+1] * Dแดฟmatrix[negative(p)][i+1,i+1] )
        end
        ฮฃโแดฟ[k][i+1,i+1]= sum
        sum=nothing
    end

    for k=1:length(V_ph)
        sum=0
        for p=1:length(V_ph)
            sum = sum+im*(ฮป๐^2/2)*( 0 + Gแดทmatrix[sumBZ1d(k,p)][i+1,i+1] * Dแดทmatrix[negative(p)][i+1,i+1]  )
        end
        ฮฃโแดท[k][i+1,i+1]=sum
        sum=nothing
    end

end


#%%

#Plotting

set
using Plots
Tโ
T๐
testk=1
testrange =80
#a,b = Array{ComplexF64}(undef,testrange),Array{ComplexF64}(undef,testrange)
b2=[]
a2=[]
for m=1:length(V_ph)
    a= Array{Float64}(undef,testrange)
    b = Array{Float64}(undef,testrange)
    for i=1:testrange
        #a[i] = Dแดฟmatrix[testk][i,1]
        #b[i] = Gแดฟmatrix[testk][i,1]
        a[i] =  (real(im*Dแดทmatrix[m][i,i])*ฯ๐(m)-1)*0.5            #real(im*Dแดทmatrix[testk][i,i])*ฯ๐(testk)
        b[i] = (imag(Gแดทmatrix[m][i,i])+1 )*0.5
    end
    push!(b2,b)
    push!(a2,a)
end


#real(b2)
plot(real(b2),lw= 3,title = "Tโ = $(Tโ), Tphonon = $(T๐)")



savefig(figpath*"testing_order_of_filling1")
plot(real(a2),legend = false)

t= collect(h:h:testrange*h)

plot(t,real(b),label="nโ(k,t,t) electrons")
plot!(t,real(a),label="n๐(k,t,t) phonons", title= "For Tโ=$(Tโ), T_phonon = $(T๐), # of modes=$(sitenum)")

#plot!(t,imag(b2),label="nโ(k,t,t) electrons")


#plot(t,real(a),label="phonons" )



figpath = "/Users/gurukalyanjayasingh/Desktop/Julia/Plots/"

savefig(figpath*"fig4.png")

for m=1:length(b)
    println(1+imag(b[m]))
end



#Disperion plots
disp_phonon=[]
disp_electron= []
for m=1:length(V_ph)
    push!(disp_phonon,ฯ๐(m))
    push!(disp_electron,ฯตโ(m))
end

plot(disp_phonon)
plot(disp_electron)
savefig(figpath*"dispersion2.png")
#%% Code ends

Tโ
T๐

arr1 =[]

for m=1:length(V_ph)
    push!(arr1, im*Gโแดท(m,1,1,Tโ,ฮผ))
end
arr1

plot(arr1)

#%%
Debugging

matinit()
boxinit()
f4 = function()
    for i=2:12  ### The diagonal value #should probably start from 2



        #Update DR
        for k=1:length(V_ph)
            for j=1:i

                if j<i
                    Dฬแดฟmatrix[k][i,j] = ฯ๐(k)^2 * Dโแดฟ(k,i,i-1) * Dแดฟmatrix[k][i-1,j] - Dฬโแดฟ(k,i,i-1) * Dฬแดฟmatrix[k][i-1,j] + (h/2)*( Dฬโแดฟ(k,i,i)* F(k,i,j) + Dฬโแดฟ(k,i,i-1) * F(k,i-1,j) )
                end
                Dแดฟmatrix[k][i+1,j] = Dฬโแดฟ(k,i+1,i) * Dแดฟmatrix[k][i,j] + Dโแดฟ(k,i+1,i) * Dฬแดฟmatrix[k][i,j] + (h/2)*Dโแดฟ(k,i+1,i)*F(k,i,j)
            end
        end

         #Update DK
         for k = 1:length(V_ph)
             for j=1:i
                 Dฬแดทmatrix[k][i,j] = ฯ๐(k)^2 * Dโแดฟ(k,i,i-1) * Dแดทmatrix[k][i-1,j] - Dฬโแดฟ(k,i,i-1) * Dฬแดทmatrix[k][i-1,j] + (h/2)*(  Dฬโแดฟ(k,i,i)* RK(k,i,j) + Dฬโแดฟ(k,i,i-1)* RK(k,i-1,j) + Dฬโแดฟ(k,i,i)* KA(k,i,j) + Dฬโแดฟ(k,i,i-1)* KA(k,i-1,j) )
                 Dแดทmatrix[k][i+1,j] = Dฬโแดฟ(k,i+1,i) * Dแดทmatrix[k][i,j] + Dโแดฟ(k,i+1,i) * Dฬแดทmatrix[k][i,j] + (h/2)*( Dโแดฟ(k,i+1,i)* RK(k,i,j) + Dโแดฟ(k,i+1,i)* KA(k,i,j) )
                 Dแดทmatrix[k][j,i+1] = -conj(Dแดทmatrix[k][i+1,j])
                 Dฬแดทmatrix[k][j,i] = +conj(Dฬแดทmatrix[k][i,j])#what abt i,i entry? If Dk is imaginary, then it will just flip sign here.....? This term is to take care of that...Not sure
             end
         end

        # Update GR, GK
        for k = 1 : length(V_ph)
            for j=1:i
                Gแดฟmatrix[k][i+1,j] = im*Gโแดฟ(k,i+1,i)*Gแดฟmatrix[k][i,j] + (h/2)* Gโแดฟ(k,i+1,i)*(Fโ(k,i,j))
                Gแดทmatrix[k][i+1,j] = im*Gโแดฟ(k,i+1,i)*Gแดทmatrix[k][i,j]+ (h/2)*Gโแดฟ(k,i+1,i)* (RKโ(k,i,j) + KAโ(k,i,j))
                Gแดทmatrix[k][j,i+1] = - conj(Gแดทmatrix[k][i+1,j]) # iGแดท is hermitian  โน iGแดท(1,2) = conj((iGแดท(2,1)) โน Gแดท(1,2) = - conj(Gแดท(2,1))
            end
        end


        # Extract Phonon self energy ฮฃ๐แดท,ฮฃ๐แดฟ in the n+1,n+1 block (use in Dr calculation in next loop)
        # ฮฃ๐แดฟ update
        for j=1:i
            for k=1:length(V_ph)
                sum=0
                for p=1:length(V_ph)
                    sum = sum -im*(ฮป๐^2/2)*(Gแดฟmatrix[sumBZ1d(k,p)][i+1,j]*Gแดทmatrix[p][j,i+1] + Gแดทmatrix[sumBZ1d(k,p)][i+1,j]* conj(Gแดฟmatrix[p][i+1,j]) )
                end
                ฮฃ๐แดฟ[k][i+1,j]=sum
                sum=nothing
            end
        end

        # ฮฃ๐แดท Update
        for j=1:i
            for k=1:length(V_ph)
                sum1=0
                sum2=0
                for p=1:length(V_ph)
                    ### Code for lower edge
                    sum1 = sum1 - im*(ฮป๐^2/2)*( Gแดฟmatrix[sumBZ1d(k,p)][i+1,j]*conj(Gแดฟmatrix[p][i+1,j]) - Gแดทmatrix[sumBZ1d(k,p)][i+1,j]*conj(Gแดทmatrix[p][i+1,j])  )

                    ### Code for upper edge
                    sum2 = sum2- im*(ฮป๐^2/2)*( conj(Gแดฟmatrix[sumBZ1d(k,p)][i+1,j])*Gแดฟmatrix[p][i+1,j] - Gแดทmatrix[sumBZ1d(k,p)][j,i+1]*conj(Gแดทmatrix[p][j,i+1]) )
                end
                ฮฃ๐แดท[k][i+1,j]= sum1
                ฮฃ๐แดท[k][j,i+1]= sum2
                sum1=nothing
                sum2=nothing
            end
        end

        #Now extract self energies ฮฃโแดฟ,ฮฃโแดท in the n+1,n+1 block (shall be used for calculation of GR in n+2,n+2 loop i.e. next big loop's GR,GK update since you're dropping the self consistent term)

        ## ฮฃโแดฟ Update
        for j=1:i
            for k=1:length(V_ph)
                sum=0
                for p=1:length(V_ph)
                    sum = sum + im*( ฮป๐^2/2 )*( Gแดฟmatrix[sumBZ1d(k,p)][i+1,j] * Dแดทmatrix[negative(p)][i+1,j] + Gแดทmatrix[sumBZ1d(k,p)][i+1,j] * Dแดฟmatrix[negative(p)][i+1,j] )
                end
                ฮฃโแดฟ[k][i+1,j]= sum
                sum=nothing
            end
        end

        ## ฮฃโแดท Update
        for j=1:i
            for k=1:length(V_ph)
                sum1=0
                sum2=0
                for p=1:length(V_ph)
                    ## code for upper edges
                    sum1 = sum1+im*(ฮป๐^2/2)*( Gแดฟmatrix[sumBZ1d(k,p)][i+1,j] * Dแดฟmatrix[negative(p)][i+1,j] + Gแดทmatrix[sumBZ1d(k,p)][i+1,j] * Dแดทmatrix[negative(p)][i+1,j]  )

                    ## code for lower edges
                    sum2 = sum2+ im*(ฮป๐^2/2)*( conj( Gแดฟmatrix[sumBZ1d(k,p)][i+1,j] )* Dแดฟmatrix[p][i+1,j] - conj( Gแดทmatrix[sumBZ1d(k,p)][i+1,j] ) * Dแดทmatrix[p][i+1,j] )
                end
                ฮฃโแดท[k][i+1,j]=sum1
                ฮฃโแดท[k][j,i+1]=sum2
                sum1=nothing
                sum2=nothing
            end
        end

        ############## Diagonal terms update #############

        if i==10
            @bp
        end
        #Update GK(t+ฯต,t+ฯต) i.e GK(i+1,i+1) here  - needs ฮฃโแดฟ on the i+1 block edges  i.e.
        for k=1:length(V_ph)
            Gแดทmatrix[k][i+1,i+1] = im*Gโแดฟ(k,i+1,i)*Gแดทmatrix[k][i,i+1]+ (h/2)*Gโแดฟ(k,i+1,i)* (RKโ(k,i,i+1) + KAโ(k,i,i+1))
        end
        #initialie Gr(i+1,i+1) = -im from before i.e. outside this loop

        #updating ฮฃ๐แดฟ[i+1,i+1],ฮฃ๐แดท[i+1,i+1]
        for k=1:length(V_ph)
            sum=0
            for p=1:length(V_ph)
                sum = sum -im*(ฮป๐^2/2)*( Gแดฟmatrix[sumBZ1d(k,p)][i+1,i+1]*Gแดทmatrix[p][i+1,i+1] + Gแดทmatrix[sumBZ1d(k,p)][i+1,i+1]* conj(Gแดฟmatrix[p][i+1,i+1]) )
            end
            ฮฃ๐แดฟ[k][i+1,i+1]=sum
            sum=nothing
        end
        #- this will be used to update the DR[i+1,i+1]

        #updating ฮฃ๐แดท(i+1,i+1)
        for k=1:length(V_ph)
            sum=0
            for p=1:length(V_ph)
                sum = sum - im*(ฮป๐^2/2)*( Gแดฟmatrix[sumBZ1d(k,p)][i+1,i+1]*conj(Gแดฟmatrix[p][i+1,i+1]) - Gแดทmatrix[sumBZ1d(k,p)][i+1,i+1]*conj(Gแดทmatrix[p][i+1,i+1])  )
            end
            ฮฃ๐แดท[k][i+1,i+1] = sum
            sum=nothing
        end

        if i==10
            @bp
        end
        #Update DK(t+ฯต,t+ฯต) here, Dฬ(i,i) block is calculated already
        for k=1:length(V_ph)
            Dฬแดทmatrix[k][i+1,i] = ฯ๐(k)^2 * Dโแดฟ(k,i+1,i) * Dแดทmatrix[k][i,i] - Dฬโแดฟ(k,i+1,i) * Dฬแดทmatrix[k][i,i] + (h/2)*(  Dฬโแดฟ(k,i+1,i+1)* RK(k,i+1,i) + Dฬโแดฟ(k,i+1,i)* RK(k,i,i) + Dฬโแดฟ(k,i+1,i+1)* KA(k,i+1,i) + Dฬโแดฟ(k,i+1,i)* KA(k,i,i) )
            Dฬแดทmatrix[k][i,i+1] = conj( Dฬแดทmatrix[k][i+1,i] )
            Dแดทmatrix[k][i+1,i+1] = Dฬโแดฟ(k,i+1,i) * Dแดทmatrix[k][i,i+1] + Dโแดฟ(k,i+1,i) * Dฬแดทmatrix[k][i,i+1] + (h/2)*( Dโแดฟ(k,i+1,i)* RK(k,i,i+1) + Dโแดฟ(k,i+1,i)* KA(k,i,i+1) )
        end

        #updating sigmElR, sigmaElK here (given that now you've all Gfuncs at the i+1,i+1)
        for k=1:length(V_ph)
            sum=0
            for p=1:length(V_ph)
                sum = sum + im*( ฮป๐^2/2 )*( Gแดฟmatrix[sumBZ1d(k,p)][i+1,i+1] * Dแดทmatrix[negative(p)][i+1,i+1] + Gแดทmatrix[sumBZ1d(k,p)][i+1,i+1] * Dแดฟmatrix[negative(p)][i+1,i+1] )
            end
            ฮฃโแดฟ[k][i+1,i+1]= sum
            sum=nothing
        end

        for k=1:length(V_ph)
            sum=0
            for p=1:length(V_ph)
                sum = sum+im*(ฮป๐^2/2)*( 0 + Gแดทmatrix[sumBZ1d(k,p)][i+1,i+1] * Dแดทmatrix[negative(p)][i+1,i+1]  )
            end
            ฮฃโแดท[k][i+1,i+1]=sum
            sum=nothing
        end
        println(i)
    end
end


@run f4()


g(x) = x^3

f(x) = g(x)+x

f(2)
