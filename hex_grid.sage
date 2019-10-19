### code for Sandpile Model on a hexagonal grid.
### firing a node in grid assumes all nodes have 6 outgoing edges 
### and boundary edges to go the global sink

def Neighbors(M,i,j):
    r = M.nrows()
    rows = []
    cols = []
    udiag = []
    ddiag = []
    if j>=i+(r+1)/2 or j<=i-(r+1)/2:
        return []
    if j<i+(r-1)/2:
        if i>0:
            rows.append(i-1)
        if j<r-1:
            cols.append(j+1)
    if j>i-(r-1)/2:
        if i<r-1:
            rows.append(i+1)
        if j>0:
            cols.append(j-1)
    if i>0 and j>0:
        udiag.append(i-1)
    if i<r-1 and j<r-1:
        ddiag.append(i+1)
    return [[a,j] for a in rows]+[[i,b] for b in cols]+[[d,j-1] for d in udiag]+[[e,j+1] for e in ddiag]
        

def chipFire(M,i,j):  #### side effect on M!!!! 
    changed = False
    if M[i,j]>5:
        changed = True
        M[i,j] = M[i,j]-6
        for [a,b] in Neighbors(M,i,j):
            M[a,b] += 1
    return changed     

def blitzFire(M):
    changed = True
    while changed == True:
        changed = False
        for i in range(M.nrows()):
            for j in range(M.ncols()):
                if chipFire(M,i,j):
                    changed = True
    M                
 
def hexShapeColor(i,j,size,color):
    return polygon([(i,j),(i+size/2,j-size/(2*sqrt(3))),(i+size,j),(i+size,j+size/sqrt(3)),(i+size/2,j+3*size/(2*sqrt(3))),(i,j+size/sqrt(3))],rgbcolor=color,fill=True)
        
def matrixPlot(M,colors):
    hexes = []
    r = M.nrows()
    c = M.ncols()
    for i in range(r):
        for j in range(c):
            if j<i+(r+1)/2 and j>i-(r+1)/2:
                hexes.append(hexShapeColor((r+2)/4+j-i/2,sqrt(3)*(r-i)/2+1,1,colors[M[i,j]]))
    return sum(hexes)

def SPconstant(c,m):
    M = constantMatrix(c,2*m+1,2*m+1)
    blitzFire(M)        
    return M


def SPidentityElem(m):            ## m is the number of hexagons on one side of the large hexagonal grid
    M = constantMatrix(10,2*m+1,2*m+1)   ## 10 = 2*deg(v)-2
    blitzFire(M)
    M=constantMatrix(10,2*m+1,2*m+1)-M
    blitzFire(M)
    return M
    
def SPidentityElem2(n):
    M = constantMatrix(6,n,n)   ## 6 = 2*deg(v)-2
    C = constantMatrix(0,n,n)   ## 6 = 2*deg(v)-2
    blitzFire2(M,C)
    M=constantMatrix(6,n,n)-M
    blitzFire2(M,C)
    return [M,C]



def SPcentralPile(c,m):
    M = matrix(2*m+1)
    M[m,m]=c
    blitzFire(M)
    return M
    

def constantMatrix(a,r,c):  ## a = value in every entry, r = rows, c=columns
    M= matrix(r,c,lambda i,j: a)
    return M
