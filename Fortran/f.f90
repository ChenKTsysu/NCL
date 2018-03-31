program ex1
implicit none
real x,a,b,c,c1,x0,i,y

a=1
b=1.5
c=1.25
y=8*x**3-4*x-5
do while (abs(c-c1)>=0.005)
    if (y>0) then
    	b=c
    	c1=c
    	c=0.5*(a+b)
    else
    	b=c
    	c1=c
    	c=0.5*(a+b)
    end if 
    i=i+1
    write(*,*) x
end do

write(*,*) i
end