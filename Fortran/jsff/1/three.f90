program three
	implicit none
	real:: fx,ff,x0,x,e
	e=2.71828
	x0=1.
	fx=x0-2*e**(x0/2)
	ff=1-x0*e**(x0/2)
	do while(.true.)
	    x=fx/ff
	    if(abs(x-x0)<=0.00005) exit
	    x0=x
	    fx=x0-2*e**(x0/2)
	    ff=1-x0*e**(x0/2)
	end do
	print*,"the root is x=",x    
end program three
