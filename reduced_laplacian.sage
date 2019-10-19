def edgeList(k):                      ### k is the side length of the square grid
    if k==1:
        return []
    if k==2:
        return [[0,1],[0,3],[1,2],[2,3]]
    corners = []
    a=0
    step=1
    while a<k^2-k:
        corners.append(a+step)
        corners.append(a+2*step)
        a=a+2*step
        step += 1
    list = [[i,i+1] for i in range(k^2-1)]
    list.extend([[0,3],[0,5],[0,7]])
    step=7
    for j in range(1,k^2-4*k+4):
        list.append([j,j+step])
        if j in corners:
            step += 2
            list.append([j,j+step])
    list.append([k^2-4*k+4,k^2-1])
    return list
    
def hexEdgeList(k):                     ### k is the side length of the hex grid
    if k==1:
        return []
    corners = []
    a=0
    step=1
    while a<3*k*(k-1)+1:
        corners.extend([a+step,a+2*step,a+3*step,a+4*step,a+5*step,a+6*step+1])
        a=a+6*step
        step+=1
    list=[[i,i+1] for i in range(3*k*(k-1))]
    list.extend([[0,2],[0,3],[0,4],[0,5],[0,6],[1,6]])
    step=6
    for j in range(1,3*k*(k-1)+1-6*(k-1)):
        list.append([j,j+step])
        list.append([j,j+step+1])
        if j in corners:
            list.append([j,j+step+2])
            step +=1
    list.append([3*k*(k-1)+1-6*(k-1),3*k*(k-1)])
    return list
    
    
def squareLaplacian(k):                   ### k is the side length of the square grid
    M = 4*matrix.identity(k^2)
    for [a,b] in edgeList(k):
        M[a,b]=-1
        M[b,a]=-1
    return M
    
def hexLaplacian(k):                   ### k is the side length of the square grid
    M = 6*matrix.identity(3*k*(k-1)+1)
    for [a,b] in hexEdgeList(k):
        M[a,b]=-1
        M[b,a]=-1
    return M
