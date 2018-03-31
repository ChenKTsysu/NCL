program one
	implicit none
	real a,b,x,f1,f2,fx
	a=1.0
	b=1.5
	do while(abs(a-b)>=0.005)
		x=(a+b)/2.
		f1=8*a**3-4*a-5
		f2=8*b**3-4*b-5
		fx=8*x**3-4*x-5
		if((f1*fx)<=0) then
			b=x
		else 
			a=x
		end if
	end do
	print*,"the root is ",x
end program one