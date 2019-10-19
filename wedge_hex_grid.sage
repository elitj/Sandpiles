### code for Sandpile Model on a hexagonal grid
### optimized by restricting to the fundamental chamber
### firing a node in grid assumes all nodes have 6 outgoing edges 
### and boundary edges to go the global sink

def hexWedgeNeighbors(M,i,j):  ### This version works for an (ceil(n/2) by n) matrix
    r=M.nrows()                ### that contains grid cells whose argument runs from
    c=M.ncols()                ### -pi/6 to 0 in polar coordinates.
    links = []
    if 2*i>j:
        return links
    if i>0:
        links.append([i-1,j-1])
        links.append([i-1,j])
    if 2*i<j:
        links.append([i,j-1])
    if j<c-1:
        links.append([i,j+1])
        if 2*i<j:
            links.append([i+1,j+1])
    if 2*i+1<j:
        links.append([i+1,j])
    return links
    
def hexNeighbors(M,i,j):     ### For use only in non-symmetric chip configurations
    n=(M.nrows()+1)/2        ### If n is the hex grid side length, uses a 2n-1 by 2n-1 matrix
    links = []
    if j>i+n-1 or j<i-n+1:
        return links
    if j<i+n-1:
        if i>0:
            links.append([i-1,j])
        if j<2*n-2:
            links.append([i,j+1])
    if j>i-n+1:
        if j>0:
            links.append([i,j-1])
        if i<2*n-2:
            links.append([i+1,j])
    if i>0 and j>0:
        links.append([i-1,j-1])
    if j<2*n-2 and i<2*n-2:
        links.append([i+1,j+1])
    return links

def petersenNeighbors(i):
    if i%3==0:
        return [(i-1)%9,(i+1)%9]
    if i%3==1:
        return [(i-1)%9,(i+1)%9,(i+4)%9]
    if i%3==2:
        return [(i-1)%9,(i+1)%9,(i-4)%9]
        
def petersenIdent():
    M = constantMatrix(4,3,3)
    petersenBlitzFire(M)
    M = constantMatrix(4,3,3) - M
    petersenBlitzFire(M)
    return M
    
    
def petersenChipFire(M,i,j):
    changed = False
    if M[i,j]>2:
        changed = True
        M[i,j] = M[i,j]-3
        for a in petersenNeighbors(3*i+j):
            M[floor(a/3),a%3] += 1
    return changed
    
def petersenBlitzFire(M):
    changed = True
    while changed == True:
        changed = False
        for i in range(3):
            for j in range(3):
                if petersenChipFire(M,i,j):
                    changed = True
    return M   

def chipFire(M,i,j):          #### called by blitzFire
    changed = False
    if M[i,j]>5:
        changed = True
        M[i,j] = M[i,j]-6
        for [a,b] in hexNeighbors(M,i,j):
            M[a,b] += 1
    return changed     
    
def chipFireOdom(M,C,i,j):    #### Called by blitzFireOdom
    changed = False
    if M[i,j]>5:
        changed = True
        C[i,j] = C[i,j]+1
        M[i,j] = M[i,j]-6
        for [a,b] in hexNeighbors(M,i,j):
            M[a,b] += 1
    return changed

def blitzFire(M):             #### Use ONLY for non-symmetric chip configurations on the full hex grid
    changed = True            #### and you don't need odometer data
    while changed == True:
        changed = False
        for i in range(M.nrows()):
            for j in range(M.ncols()):
                if chipFire(M,i,j):
                    changed = True
    M                
    
def blitzFireOdom(M,C):         #### Use ONLY for non-symmetric chip configurations on the full hex grid
    changed = True              #### also keeps track of the odometer function
    while changed == True:
        changed = False
        for i in range(M.nrows()):
            for j in range(M.ncols()):
                if chipFireOdom(M,C,i,j):
                    changed = True
    return [M,C]

def symmetryChipFire(M,i,j):        ### Called by symmetryBlitzFire
    changed = False
    if M[i,j]>5:
        changed = True
        M[i,j] = M[i,j]-6
        if 2*i+1==j:                ### Vertices adjacent to the lower wedge (but not on the plane of symmetry)
            M[i,j] += 1             ### receive 1 additional chip from their reflected neighbor when firing.
        if [i,j]==[0,1]:            ### The box [0,1] receives two extra (one accounted for above already) when
            M[i,j] += 1             ### firing, from its reflected neighbors in adjacent wedges.
        for [a,b] in hexWedgeNeighbors(M,i,j):
            if [a,b]==[0,0]:        ### When [0,0] receives a chip, it gets 5 more from its other neighbors.
                M[a,b] += 6
            elif 2*a==b:            ### When vertices on the bottom plane of symmetry receive a chip, they receive
                M[a,b] += 2         ### a second from their reflected neighbor.
            elif a==0 and i>0:      ### Likewise with vertices on the top plane of symmetry, but only from vertices
                M[a,b] += 2         ### not on the plane of symmetry.
            else:
                M[a,b] += 1         ### All other vertices
    return changed
    
    
def symmetryChipFireOdom(M,C,i,j):  ### Called by symmetryBlitzFireOdom
    changed = False
    if M[i,j]>5:
        changed = True
        C[i,j] = C[i,j]+1
        M[i,j] = M[i,j]-6
        if 2*i+1==j:                ### Vertices adjacent to the lower wedge (but not on the plane of symmetry)
            M[i,j] += 1             ### receive 1 additional chip from their reflected neighbor when firing.
        if [i,j]==[0,1]:            ### The box [0,1] receives two extra (one accounted for above already) when
            M[i,j] += 1             ### firing, from its reflected neighbors in adjacent wedges.
        for [a,b] in hexWedgeNeighbors(M,i,j):
            if [a,b]==[0,0]:        ### When [0,0] receives a chip, it gets 5 more from its other neighbors.
                M[a,b] += 6
            elif 2*a==b:            ### When vertices on the bottom plane of symmetry receive a chip, they receive
                M[a,b] += 2         ### a second from their reflected neighbor.
            elif a==0 and i>0:      ### Likewise with vertices on the top plane of symmetry, but only from vertices
                M[a,b] += 2         ### not on the plane of symmetry.
            else:
                M[a,b] += 1         ### All other vertices
    return changed    
    
def symmetryBlitzFire(M):           ### Use this anytime your chip config is symmetric and 
    changed = True                  ### you don't need odometer data
    while changed == True:
        changed = False
        for i in range(M.nrows()):
            for j in range(M.ncols()):
                if symmetryChipFire(M,i,j):
                    changed = True
    return M
    
def symmetryBlitzFireOdom(M,C):           ### Use this anytime your chip config is symmetric and 
    changed = True                        ### you want to keep track of odometer data
    while changed == True:
        changed = False
        for i in range(M.nrows()):
            for j in range(M.ncols()):
                if symmetryChipFireOdom(M,C,i,j):
                    changed = True
    return [M,C]     

def hexShapeColor(i,j,size,color):
    return polygon([(i,j),(i+size/2,j-size/(2*sqrt(3))),(i+size,j),(i+size,j+size/sqrt(3)),(i+size/2,j+3*size/(2*sqrt(3))),(i,j+size/sqrt(3))],rgbcolor=color,fill=True)
    
def pixel(i,j,size,color):
    return polygon([(i,j),(i+size,j),(i+size,j+size*sqrt(3)/2), (i,j+size*sqrt(3)/2)],rgbcolor=color, fill=True)
        
def matrixPlot(M,colors):      ## Used ONLY with the full hex matrix (non-symmetric chip configurations)
    hexes = []
    r = M.nrows()
    c = M.ncols()
    for i in range(r):
        for j in range(c):
            if j<i+(r+1)/2 and j>i-(r+1)/2:
                hexes.append(hexShapeColor((r+2)/4+j-i/2,sqrt(3)*(r-i)/2+1,1,colors[M[i,j]]))
    return sum(hexes)
    
def fullMatrixPlot(M,colors):
    hexes = []
    c = M.ncols()
    hexes.append(hexShapeColor(0,0,1,colors[M[0,0]]))
    for j in range (1,c):                                ### First color the corner axes
        hexes.append(hexShapeColor(j,0,1,colors[M[0,j]]))
        hexes.append(hexShapeColor(-j,0,1,colors[M[0,j]]))
        hexes.append(hexShapeColor(j/2,j*sqrt(3)/2,1,colors[M[0,j]]))
        hexes.append(hexShapeColor(-j/2,-j*sqrt(3)/2,1,colors[M[0,j]]))
        hexes.append(hexShapeColor(j/2,-j*sqrt(3)/2,1,colors[M[0,j]]))
        hexes.append(hexShapeColor(-j/2,j*sqrt(3)/2,1,colors[M[0,j]]))
    for i in range(1,ceil(c/2)):                         ### Then the lines through the centers of the sides
        hexes.append(hexShapeColor(3*i/2,-i*sqrt(3)/2,1,colors[M[i,2*i]]))
        hexes.append(hexShapeColor(-3*i/2,i*sqrt(3)/2,1,colors[M[i,2*i]]))
        hexes.append(hexShapeColor(3*i/2,i*sqrt(3)/2,1,colors[M[i,2*i]]))
        hexes.append(hexShapeColor(-3*i/2,-i*sqrt(3)/2,1,colors[M[i,2*i]]))
        hexes.append(hexShapeColor(0,i*sqrt(3),1,colors[M[i,2*i]]))
        hexes.append(hexShapeColor(0,-i*sqrt(3),1,colors[M[i,2*i]]))
    for i in range(1,ceil(c/2)):                         ### Then fill in the rest
        for j in range(2*i+1,c):
            hexes.append(hexShapeColor(j-i/2,-i*sqrt(3)/2,1,colors[M[i,j]]))
            hexes.append(hexShapeColor(j-i/2,i*sqrt(3)/2,1,colors[M[i,j]]))
            hexes.append(hexShapeColor(i/2-j,i*sqrt(3)/2,1,colors[M[i,j]]))
            hexes.append(hexShapeColor(i/2-j,-i*sqrt(3)/2,1,colors[M[i,j]]))
            hexes.append(hexShapeColor((i+j)/2,sqrt(3)*(j-i)/2,1,colors[M[i,j]]))
            hexes.append(hexShapeColor((i+j)/2,sqrt(3)*(i-j)/2,1,colors[M[i,j]]))
            hexes.append(hexShapeColor(-(i+j)/2,sqrt(3)*(j-i)/2,1,colors[M[i,j]]))
            hexes.append(hexShapeColor(-(i+j)/2,sqrt(3)*(i-j)/2,1,colors[M[i,j]]))
            hexes.append(hexShapeColor(j/2-i,j*sqrt(3)/2,1,colors[M[i,j]]))
            hexes.append(hexShapeColor(j/2-i,-j*sqrt(3)/2,1,colors[M[i,j]]))
            hexes.append(hexShapeColor(i-j/2,j*sqrt(3)/2,1,colors[M[i,j]]))
            hexes.append(hexShapeColor(i-j/2,-j*sqrt(3)/2,1,colors[M[i,j]]))
    return sum(hexes)
    
def cheapMatrixPlot(M,colors):
    hexes = []
    c = M.ncols()
    hexes.append(pixel(0,0,1,colors[M[0,0]]))
    for j in range (1,c):                                ### First color the corner axes
        hexes.append(pixel(j,0,1,colors[M[0,j]]))
        hexes.append(pixel(-j,0,1,colors[M[0,j]]))
        hexes.append(pixel(j/2,j*sqrt(3)/2,1,colors[M[0,j]]))
        hexes.append(pixel(-j/2,-j*sqrt(3)/2,1,colors[M[0,j]]))
        hexes.append(pixel(j/2,-j*sqrt(3)/2,1,colors[M[0,j]]))
        hexes.append(pixel(-j/2,j*sqrt(3)/2,1,colors[M[0,j]]))
    for i in range(1,ceil(c/2)):                         ### Then the lines through the centers of the sides
        hexes.append(pixel(3*i/2,-i*sqrt(3)/2,1,colors[M[i,2*i]]))
        hexes.append(pixel(-3*i/2,i*sqrt(3)/2,1,colors[M[i,2*i]]))
        hexes.append(pixel(3*i/2,i*sqrt(3)/2,1,colors[M[i,2*i]]))
        hexes.append(pixel(-3*i/2,-i*sqrt(3)/2,1,colors[M[i,2*i]]))
        hexes.append(pixel(0,i*sqrt(3),1,colors[M[i,2*i]]))
        hexes.append(pixel(0,-i*sqrt(3),1,colors[M[i,2*i]]))
    for i in range(1,ceil(c/2)):                         ### Then fill in the rest
        for j in range(2*i+1,c):
            hexes.append(pixel(j-i/2,-i*sqrt(3)/2,1,colors[M[i,j]]))
            hexes.append(pixel(j-i/2,i*sqrt(3)/2,1,colors[M[i,j]]))
            hexes.append(pixel(i/2-j,i*sqrt(3)/2,1,colors[M[i,j]]))
            hexes.append(pixel(i/2-j,-i*sqrt(3)/2,1,colors[M[i,j]]))
            hexes.append(pixel((i+j)/2,sqrt(3)*(j-i)/2,1,colors[M[i,j]]))
            hexes.append(pixel((i+j)/2,sqrt(3)*(i-j)/2,1,colors[M[i,j]]))
            hexes.append(pixel(-(i+j)/2,sqrt(3)*(j-i)/2,1,colors[M[i,j]]))
            hexes.append(pixel(-(i+j)/2,sqrt(3)*(i-j)/2,1,colors[M[i,j]]))
            hexes.append(pixel(j/2-i,j*sqrt(3)/2,1,colors[M[i,j]]))
            hexes.append(pixel(j/2-i,-j*sqrt(3)/2,1,colors[M[i,j]]))
            hexes.append(pixel(i-j/2,j*sqrt(3)/2,1,colors[M[i,j]]))
            hexes.append(pixel(i-j/2,-j*sqrt(3)/2,1,colors[M[i,j]]))
    return sum(hexes)
    
def wedgeMatrixPlot(M,colors):
    hexes = []
    r = M.nrows()
    c = M.ncols()
    for i in range(r):
        for j in range(2*i,c):
            hexes.append(hexShapeColor((r+2)/4+j-i/2,sqrt(3)*(r-i)/2+1,1,colors[M[i,j]]))
    return sum(hexes)

def wedgeConstant(c,m):
    M = constantMatrix(c,ceil(m/2),m)
    symmetryBlitzFire(M)        
    return M
    

def wedgeIdentityElem(m):                ## m is the number of hexagons on one side of the large hexagonal grid
    M = constantMatrix(10,ceil(m/2),m)   ## 10 = 2*deg(v)-2
    symmetryBlitzFire(M)
    M= constantMatrix(10,ceil(m/2),m)-M
    symmetryBlitzFire(M)
    return M

def wedgeIdentityElemOdom(m):                ## m is the number of hexagons on one side of the large hexagonal grid
    M = constantMatrix(10,ceil(m/2),m)       ## 10 = 2*deg(v)-2
    symmetryBlitzFire(M)
    M= constantMatrix(10,ceil(m/2),m)-M
    C = constantMatrix(0,ceil(m/2),m)
    symmetryBlitzFireOdom(M,C)
    return [M,C]
    
def identityElemFull(m):                   ## For use ONLY with non-symmetric chip configurations
    M = constantMatrix(10,2*m-1,2*m-1)     ## m = side length of hex grid
    blitzFire(M)
    M = constantMatrix(10,2*m-1,2*m-1)-M
    blitzFire(M)
    return M
    

    
def odomSumKthRing(C,k):                  ## First argument is the odometer matrix of a wedge, second is the ring, starting at
    if k>C.ncols():                       ## 1 for the central hex, 2 for the ring of 6 surrounding it, etc.
        print("Error: k not in range.")
        return -1
    if k==1:
        return C[0,0]
    n=6*C[0,k-1]
    if k%2 ==1:
        n+= 6*C[(k-1)/2,k-1]
    for i in range(1,floor(k/2)):
        n+=12*C[i,k-1]
    return n
        
def sinkRingOdom(m,n):  ## Generates a list showing the sum of the odometer function
    if n<m:             ## across the outer ring of (i.e. neighbors of the sink) grids size m to n
        print("Error: second argument cannot be smaller than the first.")
        return -1
    h=[0 for i in range(m,n+1)]
    for j in range(m,n+1):
        M=wedgeIdentityElemOdom(j)
        h[j-m]=odomSumKthRing(M[1],j)
    return h
    
def sinkRingOdomStepOne(m,n):  ## Generates a list showing the sum of the odometer function (step one)
    if n<m:                    ## across the outer ring of (i.e. neighbors of the sink) grids size m to n
        print("Error: second argument cannot be smaller than the first.")
        return -1
    h=[0 for i in range(m,n+1)]
    for j in range(m,n+1):
        M=odomStepOne(j)
        h[j-m]=odomSumKthRing(M[1],j)
    return h
    
def centerHexOdom(m,n):
    if n<m:
        print("Error: second argument can't be smaller than first.")
        return -1
    h=[0 for i in range(m,n+1)]
    for j in range(m,n+1):
        M=wedgeIdentityElemOdom(j)
        h[j-m]=M[1][0,0]
    return h
    
def centerHexOdomStepOne(m,n):
    if n<m:
        print("Error: second argument can't be smaller than first.")
        return -1
    h=[0 for i in range(m,n+1)]
    for j in range(m,n+1):
        M=odomStepOne(j)
        h[j-m]=M[1][0,0]
    return h

def wedgeCentralPile(c,m):
    M = matrix(ceil(m/2),m)
    M[0,0]=c
    symmetryBlitzFire(M)
    return M
    
def addChipsCentralPile(C,chips):
    C[0,0]+=chips
    symmetryBlitzFire(C)
    return C    
    
def addChipsAndScale(M,current,add):
    newcols = max(26,ceil(sqrt(current+add)/2.85))
    if newcols == M.ncols():
        return addChipsCentralPile(M,add)
    C = matrix(ceil(newcols/2),newcols)
    for i in range(min(C.nrows(),M.nrows())):
        for j in range(min(C.ncols(),M.ncols())):
            C[i,j]=M[i,j]
    D = addChipsCentralPile(C,add)
    return D
    
def odomStepOne(m):                ## m is the number of hexagons on one side of the large hexagonal grid
    M = constantMatrix(10,ceil(m/2),m)       ## 10 = 2*deg(v)-2
    C = constantMatrix(0,ceil(m/2),m)
    symmetryBlitzFireOdom(M,C)
    return [M,C]

def constantMatrix(a,r,c):  ## a = value in every entry, r = rows, c=columns
    M= matrix(r,c,lambda i,j: a)
    return M
    
def wedgeIdentityComparison(m):            ### returns a matrix that is the difference between
    M = constantMatrix(10,ceil(m/2),m)     ## the identity element and the last step before it blitzfires
    symmetryBlitzFire(M)
    M= constantMatrix(10,ceil(m/2),m)-M
    M=M-symmetryBlitzFire(M)
    return M
    
def radiusCentralPile(n):
    if n<6:
        return 1
    M=wedgeCentralPile(n,ceil(sqrt(n/3)+2))
    for j in range(1,ceil(sqrt(n/3)+1)):
        for i in range(ceil((j+1)/2)):
            if M[i,j]!=0:
                break
            if i==floor(j/2):
                return j
    print("Error: checker reached the edge of the graph")
    return -1
    
def radius(M):
    for j in range(1,M.ncols()):
        for i in range(ceil((j+1)/2)):
            if M[i,j]!=0:
                break
            if i==floor(j/2):
                return j
    print("Error: checker reached the edge of the graph")
    return -1
    
def centralPileList(beginval, finalval, stepsize, *startingMatrix):
    if startingMatrix:
        pile = startingMatrix[0]
        list = [deepcopy(pile)]
    else:
        pile = wedgeCentralPile(beginval,max(26,ceil(sqrt(beginval)/2.85)))
        list = [deepcopy(pile)]
    chips = beginval
    for i in range(beginval, finalval, stepsize):
        pile = addChipsAndScale(pile,i,stepsize)
        list.append(deepcopy(pile))
    return list   

def reduceWedge(M):
    if ceil(M.ncols()/2)==M.nrows():
        for j in range(1,M.ncols()):
            for i in range(M.nrows()):
                if M[i,j]!=0:
                    break
                if i==M.nrows()-1:
                    return M[:ceil(j/2),:j]
        return M
    print ("matrix has incorrect dimensions for reduceWedge")
    return -1
    
def cheapReduceWedge(M, chips):
    if M.ncols()<= 10:
        return M
    if chips < 6018:
        return reduceWedge(M)
    newcols = ceil(sqrt(chips)/2.85)
    return M[:ceil(newcols/2),:newcols]

        
def radiusRange(m,n):
    return [radiusCentralPile(i) for i in range(m,n)]
    
def radiusTable(m,n):
    list = [[m,radiusCentralPile(m)]]
    currentRadius=radiusCentralPile(m)
    for i in range(m+6,n,6):
        if radiusCentralPile(i)>currentRadius:
            currentRadius+=1
            list.append([i,currentRadius])
    return list
    
def wedgeIsRecurrent(M):
    c=M.ncols()
    r=M.nrows()
    if r!=ceil(c/2):
        print("Matrix has incorrect shape")
        return False
    I=wedgeIdentityElem(c)
    return symmetryBlitzFire(M+I)==M
    
def isRecurrent(M):
    c=M.ncols()
    r=M.nrows()
    if c!=r:
        print("Matrix is not square")
        return False
        
def colorVector(wedge):  # Returns a vector counting the number of 0's,..., 5's on the full hex
    vector = [0,0,0,0,0,0]
    vector[wedge[0,0]]=1
    for j in range(1,wedge.ncols()):
        vector[wedge[0,j]]+=6
    for i in range(1,wedge.nrows()):
        vector[wedge[i,2*i]]+=6
        for j in range(2*i+1,wedge.ncols()):
            vector[wedge[i,j]]+=12
    n = 3*wedge.ncols()*(wedge.ncols()+1)+1
    print " Zeros  = ", vector[0],"\n    pct = ", float(vector[0]/n),"\n Ones   = ", vector[1],"\n    pct = ", float(vector[1]/n),"\n Twos   = ",vector[2],"\n    pct = ", float(vector[2]/n),"\n Threes = ",vector[3],"\n    pct = ", float(vector[3]/n),"\n Fours  = ",vector[4],"\n    pct = ", float(vector[4]/n),"\n Fives  = ",vector[5],"\n    pct = ", float(vector[5]/n)
    return None
    
import string
    
def latexArrayToMatrix(lxarray):
    lxarray = lxarray[lxarray.find('array}{')+7:]
    if lxarray[0] == 'c':
        width = lxarray.find('c}')+1
    elif lxarray[0] == 'l':
        width = lxarray.find('l}')+1
    elif lxarray[0] == 'r':
        width = lxarray.find('r}')+1
    else:
        print('Something went wrong')
        return None
    lxarray = lxarray[width+1:lxarray.find('end')]
    lxarray = lxarray.translate(string.maketrans('', ''), '&{}\n \\')
    M = matrix(ceil(width/2),width)
    currentrow = -1
    for i in range(len(lxarray)):
        if i % width == 0:
            currentrow += 1
        M[currentrow, i%width] = lxarray[i]
    return M
