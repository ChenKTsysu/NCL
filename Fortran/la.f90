program lagrange
    implicit none
!*******lagrange******************************
    real :: x(4),y(4),l(4),x0=1.5,ln,f(3)
    integer ::i=1,j=1
    x=(/0,2,3,5/)
    y=(/1,3,7,21/)
    l=1
    do i=1,4
    	do j=1,i-1
    		l(i)=l(i)*((x0-x(j))/(x(i)-x(j)))
    	end do
    	do j=i+1,4
    		l(i)=l(i)*((x0-x(j))/(x(i)-x(j)))
    	end do 
    	ln=l(i)*y(i)
    end do
    print*,ln
!*******Newton************************************* 
    do j=3,2
    	do i=3,1
    		f(i)=(y(i+1)-y(i))/(x(i+1)-x(i))
        end do
    	f(j)=(f(j)-f(j-1))/(x(j+1)-x(j-1))
    end do

end




    
