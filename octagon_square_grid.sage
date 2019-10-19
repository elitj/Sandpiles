### code for Sandpile Model on an octagon/square tessellating grid.
### Implemented with the boundary a large square made entirely of octagons, with squares in between rows and at a
### 45 degree angle. All boundary edges to go the global sink.

def Neighbors(M,i,j):
    c = M.ncols()
    r = M.nrows()
    links = []
    if i%2==0:
        if i>0:
            links.append([i-2,j])  ### North
            if j>0:
                links.append([i-1,j-1])  ### Northwest
            if j<c-1:
                links.append([i-1,j])  ### Northeast
        if i<r-1:
            links.append([i+2,j])  ### South
            if j>0:
                links.append([i+1,j-1])  ### Southwest
            if j<c-1:
                links.append([i+1,j])  ### Southeast
        if j>0:
            links.append([i,j-1])  ### West
        if j<c-1:
            links.append([i,j+1])  ### East
    elif j<c-1:
        links=[[i-1,j],[i-1,j+1],[i+1,j],[i+1,j+1]]
    return links
        

def chipFire(M,i,j):  #### side effect on M!!!! 
    changed = False
    if M[i,j]>7 and i%2==0:
        changed = True
        M[i,j] = M[i,j]-8
        for [a,b] in Neighbors(M,i,j):
            M[a,b] += 1
    if M[i,j]>3 and i%2==1:
        changed = True
        M[i,j] = M[i,j]-4
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
 
def octShapeColor(i,j,size,color):
    return polygon([(i,j),(i+size,j),(i+(1+sqrt(2)/2)*size,j+sqrt(2)*size/2),(i+(1+sqrt(2)/2)*size,j+(1+sqrt(2)/2)*size),(i+size,j+(1+sqrt(2))*size),(i,j+(1+sqrt(2))*size),(i-sqrt(2)*size/2,j+(1+sqrt(2)/2)*size),(i-sqrt(2)*size/2,j+sqrt(2)*size/2)],rgbcolor=color,fill=True)
    
def sqShapeColor(i,j,size,color):
    return polygon([(i,j),(i+sqrt(2)*size/2,j-sqrt(2)*size/2),(i+sqrt(2)*size,j),(i+sqrt(2)*size/2,j+sqrt(2)*size/2)],rgbcolor=color, fill=True)
        
def matrixPlot(M,colors):
    shapes = []
    r = M.nrows()
    c = M.ncols()
    for i in range(r):
        for j in range(c):
            if i%2==0:
                shapes.append(octShapeColor(2+(1+sqrt(2))*j,(1+sqrt(2))*(r-i/2),1,colors[M[i,j]]))
            if i%2==1 and j<c-1:
                shapes.append(sqShapeColor(3+(1+sqrt(2))*j,(1+sqrt(2))*(r-(i-1)/2),1,colors[M[i,j]]))
    return sum(shapes)

def SPconstant(c,m):
    M = constantMatrix(c,2*m-1,m)
    blitzFire(M)        
    return M


def SPidentityElem(m):            ## m is the number of octagons on one side of the large grid
    M = constantMatrix(16,2*m-1,m)   ## 16 = 2*deg(v)-2
    blitzFire(M)
    M=constantMatrix(16,2*m-1,m)-M
    blitzFire(M)
    return M


### def SPcentralPile(c,m):
###    M = matrix(2*m+1)
###    M[m,m]=c
###    blitzFire(M)
###    return M
    

def constantMatrix(a,r,c):  ## a = value in every entry, r = rows, c=columns
    M= matrix(r,c,lambda i,j: a)
    return M
