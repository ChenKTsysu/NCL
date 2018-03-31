program two
	implicit none
	!f(x)=x**3-x**2-x-1
	real x0,x1,x2,x3
	integer :: i=0,j=0,k=0
	x0=1.
!*********************************************************************
	do while(i<10000)
		i=i+1
		x1=(x0**2+x0+1)**(1./3.)
		if(abs(x1-x0)<=0.005) exit
		x0=x1
		print*,x1
	end do
	print*,"the root is",x1
	!**************************************************************
	do while(j<10000)
		j=j+1
		x2=1.+1./x0+1./x0**2
		if(abs(x2-x0)<=0.005) exit
		x0=x2
		print*,x2
	end do
	print*,"the root is",x2
	!*********************************************************************
	do while(k<10000)
		k=k+1
		x3=x0**3-x0**2+1
		if(abs(x3-x0)<=0.005) exit
		x0=x3
	end do
	print*,x3

print*,i,j,k
    
end program two