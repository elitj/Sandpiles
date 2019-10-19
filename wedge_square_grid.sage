### code for Sandpile Model on a square grid.
### firing a node in grid assumes all nodes have 4 outgoing edges 
### and boundary edges to go the global sink

def sqWedgeNeighbors(M,i,j):  ###Neighbors function for wedge of square grid
    c = M.ncols()
    links = []
    if i>j:
        return links
    if i>0:
        links.append([i-1,j])
    if i<j:
        links.append([i+1,j])
        links.append([i,j-1])
    if j<c-1:
        links.append([i,j+1]) 
    return links
        
def sqNeighbors(M,i,j):  ### For use only in non-symmetric chip configurations
    links = []
    if i>0:
        links.append([i-1,j])
    if i<M.nrows()-1:
        links.append([i+1,j])
    if j>0:
        links.append([i,j-1])
    if j<M.ncols()-1:
        links.append([i,j+1])
    return links

def evenChipFire(M,i,j):  #### chip firing on wedge of even size grid 
    changed = False
    if M[i,j]>3:
        changed = True
        M[i,j] = M[i,j]-4
        if i==0:
            M[i,j] += 1
            if j==0:
                M[i,j] += 1
        for [a,b] in sqWedgeNeighbors(M,i,j):
            if a==b:
                M[a,b] += 2
            else:
                M[a,b] += 1
    return changed     
    
def oddChipFire(M,i,j): ### chip firing on wedge of odd size grid 
    changed = False
    if M[i,j]>3:
        changed = True
        M[i,j] = M[i,j]-4
        for [a,b] in sqWedgeNeighbors(M,i,j):
            if [a,b]==[0,0]:
                M[a,b] += 4
            elif a==0 and i==1:
                M[a,b] += 2
            elif a==b:
                M[a,b] += 2
            else:
                M[a,b] += 1
    return changed 


def sqChipFire(M,i,j):  ### Called by sqBlitzFire
    changed = False
    if M[i,j]>3:
        changed = True
        M[i,j] = M[i,j]-4
        for [a,b] in sqNeighbors(M,i,j):
            M[a,b] += 1
    return changed
    
def evenChipFireOdom(M,C,i,j):
    changed = False
    if M[i,j]>3:
        changed = True
        M[i,j] = M[i,j]-4
        C[i,j] += 1
        if i==0:
            M[i,j] += 1
            if j==0:
                M[i,j] += 1
        for [a,b] in sqWedgeNeighbors(M,i,j):
            if a==b:
                M[a,b] += 2
            else:
                M[a,b] += 1
    return changed 
    
def oddChipFireOdom(M,C,i,j):
    changed = False
    if M[i,j]>3:
        changed = True
        M[i,j] = M[i,j]-4
        C[i,j] += 1
        for [a,b] in sqWedgeNeighbors(M,i,j):
            if [a,b]==[0,0]:
                M[a,b] += 4
            elif a==0 and i==1:
                M[a,b] += 2
            elif a==b:
                M[a,b] += 2
            else:
                M[a,b] += 1
    return changed 
    
    

def oddBlitzFire(M):
    r=M.nrows()
    changed = True
    while changed == True:
        changed = False
        for i in range(r):
            for j in range(i,r):
                if oddChipFire(M,i,j):
                    changed = True
    M                
    
def evenBlitzFire(M):
    r=M.nrows()
    changed = True
    while changed == True:
        changed = False
        for i in range(r):
            for j in range(i,r):
                if evenChipFire(M,i,j):
                    changed = True
    M 
    
def oddBlitzFireOdom(M,C):
    r=M.nrows()
    changed = True
    while changed == True:
        changed = False
        for i in range(r):
            for j in range(i,r):
                if oddChipFireOdom(M,C,i,j):
                    changed = True
    return [M,C]

def evenBlitzFireOdom(M,C):
    r=M.nrows()
    changed = True
    while changed == True:
        changed = False
        for i in range(r):
            for j in range(i,r):
                if evenChipFireOdom(M,C,i,j):
                    changed = True
    return [M,C]

def sqBlitzFire(M):        ### For use only with non-symmetric chip configurations (uses full grid)
    r = M.nrows()
    changed = True
    while changed == True:
        changed = False
        for i in range(r):
            for j in range(r):
                if sqChipFire(M,i,j):
                    changed = True
    M

 
def squareShapeColor(i,j,size,color):
    return polygon([(i,j),(i,j+size),(i+size,j+size),(i+size,j)],rgbcolor=color,fill=True)
        
def wedgeMatrixPlot(M,colors):
    squares = []
    r = M.nrows()
    c = M.ncols()
    for i in range(r):
        for j in range(c):
            squares.append(squareShapeColor(j,r-i+1,1,colors[M[i,j]]))
    return sum(squares)
    
def sqMatrixPlot(M,colors):      ## Used ONLY with the full square matrix (non-symmetric chip configurations)
    squares = []
    r = M.nrows()
    for i in range(r):
        for j in range(r):
            squares.append(squareShapeColor(j,r-i+1,1,colors[M[i,j]]))
    return sum(squares)                


def fullSqMatrixPlotOdd(M,colors):  ## Wedge --> Full
    squares = []
    c = M.ncols()
    squares.append(squareShapeColor(0,0,1,colors[M[0,0]]))
    for j in range (1,c):
        squares.append(squareShapeColor(j,0,1,colors[M[0,j]]))
        squares.append(squareShapeColor(-j,0,1,colors[M[0,j]]))
        squares.append(squareShapeColor(0,j,1,colors[M[0,j]]))
        squares.append(squareShapeColor(0,-j,1,colors[M[0,j]]))
    for i in range(1,c):
        squares.append(squareShapeColor(i,i,1,colors[M[i,i]]))
        squares.append(squareShapeColor(-i,i,1,colors[M[i,i]]))
        squares.append(squareShapeColor(i,-i,1,colors[M[i,i]]))
        squares.append(squareShapeColor(-i,-i,1,colors[M[i,i]]))
    for i in range(1,c-1):
        for j in range(1+i,c):
            squares.append(squareShapeColor(j,-i,1,colors[M[i,j]]))
            squares.append(squareShapeColor(j,i,1,colors[M[i,j]]))
            squares.append(squareShapeColor(i,j,1,colors[M[i,j]]))
            squares.append(squareShapeColor(i,-j,1,colors[M[i,j]]))
            squares.append(squareShapeColor(-j,-i,1,colors[M[i,j]]))
            squares.append(squareShapeColor(-j,i,1,colors[M[i,j]]))
            squares.append(squareShapeColor(-i,j,1,colors[M[i,j]]))
            squares.append(squareShapeColor(-i,-j,1,colors[M[i,j]]))
    return sum(squares)

def fullSqMatrixPlotEven(M,colors):  ## Wedge --> Full
    squares = []
    c = M.ncols()
    squares.append(squareShapeColor(0,0,1,colors[M[0,0]]))    
    squares.append(squareShapeColor(0,1,1,colors[M[0,0]]))
    squares.append(squareShapeColor(-1,1,1,colors[M[0,0]]))
    squares.append(squareShapeColor(-1,0,1,colors[M[0,0]]))
    for i in range(1,c):                         ### Then the lines through the centers of the sides
        squares.append(squareShapeColor(i,i+1,1,colors[M[i,i]]))
        squares.append(squareShapeColor(i,-i,1,colors[M[i,i]]))
        squares.append(squareShapeColor(-i-1,i+1,1,colors[M[i,i]]))
        squares.append(squareShapeColor(-i-1,-i,1,colors[M[i,i]]))
    for i in range(c-1):                         ### Then fill in the rest
        for j in range(1+i,c):
            squares.append(squareShapeColor(j,-i,1,colors[M[i,j]]))
            squares.append(squareShapeColor(j,i+1,1,colors[M[i,j]]))
            squares.append(squareShapeColor(i,j+1,1,colors[M[i,j]]))
            squares.append(squareShapeColor(i,-j,1,colors[M[i,j]]))
            squares.append(squareShapeColor(-j-1,-i,1,colors[M[i,j]]))
            squares.append(squareShapeColor(-j-1,i+1,1,colors[M[i,j]]))
            squares.append(squareShapeColor(-i-1,j+1,1,colors[M[i,j]]))
            squares.append(squareShapeColor(-i-1,-j,1,colors[M[i,j]]))
    return sum(squares)


def SPconstant(c,m,n):
    M = constantMatrix(c,m,n)
    blitzFire(M)        
    return M


def wedgeIdentityElem(m):
    M = constantMatrix(6,ceil(m/2),ceil(m/2))   ## 6 = 2*deg(v)-2
    if m%2==0:
        evenBlitzFire(M)
    else:
        oddBlitzFire(M)
    M=constantMatrix(6,ceil(m/2),ceil(m/2))-M
    if m%2==0:
        evenBlitzFire(M)
    else:
        oddBlitzFire(M)
    return M
    
def wedgeIdentityElemOdom(m):
    M = constantMatrix(6,ceil(m/2),ceil(m/2))
    C = matrix(ceil(m/2))
    if m%2==0:
        evenBlitzFire(M)
    else:
        oddBlitzFire(M)
    M=constantMatrix(6,ceil(m/2),ceil(m/2))-M
    if m%2==0:
        evenBlitzFireOdom(M,C)
    else:
        oddBlitzFireOdom(M,C)
    return [M,C]
    
def odomSumKthRingO(C,k):      ### Use on the wedge for an ODD side length grid
    if k>C.ncols():
        print("Error: k not in range.")
        return -1
    if k==1:
        return C[0,0]
    n=4*C[0,k-1]+4*C[k-1,k-1]
    for i in range(1,k-1):
        n+=8*C[i,k-1]
    return n
    
def odomSumKthRingE(C,k):
    if k>C.ncols():
        print("Error: k not in range.")
        return -1
    if k==1:
        return 4*C[0,0]
    n=4*C[k-1,k-1]
    for i in range(k-1):
        n+=8*C[i,k-1]
    return n


def constantMatrix(a,r,c):  ## a = value in every entry, r = rows, c=columns
    M= matrix(r,c,lambda i,j: a)
    return M
