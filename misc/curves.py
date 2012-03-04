from Tkinter import *
 
root = Tk()

z = [154+69j, 72+99j, 215+77j]


def cabs(w):
    return w.real*w.real + w.imag*w.imag

def draw():
    print z[0],z[1],z[2]
    canv.delete(ALL)
    A = z[0]
    B = z[1] - A
    C = z[2] - A
    B2 = cabs(B)
    C2 = cabs(C)
    D = 2*(B.real*C.imag-B.imag*C.real)
    cen = 1j*(B*C2-C*B2)/D + A
    a = z[0] - cen
    b = z[1] - cen
    c = z[2] - cen
    b = a*pow(b/a,1.5) + cen;
    c = a*pow(c/a,1.5) + cen;
    a = z[0]
    point(z[0])
    point(z[1])
    point(z[2])
    r = pow(cabs(a-cen),0.5)
    bl = pow(cabs(b-a),0.5)
    db = 0.25*bl*(b-cen)/r
    dz = 0.5*bl*(z[1]-cen)/r
    bezier(a,z[1]+dz,b+db,b)
    bezier(a,z[1]-dz,b-db,b)
    cl = pow(cabs(c-a),0.5)
    dc = 0.25*cl*(c-cen)/r
    dz = 0.5*cl*(z[2]-cen)/r
    bezier(a,z[2]+dz,c+dc,c)
    bezier(a,z[2]-dz,c-dc,c)

def bezier(p1,p2,p3,p4):
    for n in range(101):
        t = 0.01*n
        w = pow(1-t,3)*p1 + 3*pow(1-t,2)*t*p2 + 3*(1-t)*pow(t,2)*p3
        w += pow(t,3)*p4
        if n > 0:
            canv.create_line(wo.real,wo.imag,w.real,w.imag)
        wo = w

def point(z):
    x = z.real
    y = z.imag 
    canv.create_oval(x-4,y-4,x+4,y+4)


def moved(event):
    w = event.x + 1j*event.y
    ds = 0
    for p in range(3):
        ds = cabs(w-z[p])
        if p==0 or ds<dsmin:
            dsmin = ds
            q = p
    z[q] = w
    draw()


canv = Canvas(root, width=300, height=300)
canv.bind("<B1-Motion>", moved)
canv.pack()
draw()
root.mainloop()

