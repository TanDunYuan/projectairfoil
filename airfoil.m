%script that takes in NACA 4 sereies airfoil, angle of attack, freestream
%velocity and number of panels on airfoil as input.
%script then returns coefficient of lift, and plot the velocity vectors and
%streamlines around the airfoil
%script created by dunyuan tan on 25/03/2018
%housekeeping
%NOTEE: if airfoil is too thin the mesh size of streamline should be smaller
%for better streamline pictures. 
clc
clear
%ask  user for input of the NACA airfoil to be used, number of panels to
%be generated, velocity of air, angle of attack
naca=input('Input NACA 4-series airfoil to be tested: ','s');
Uinf=input('Input free stream airspeed (m/s): ');
alpha=input('Input airfoil angle of attack (deg): ');
alpha=deg2rad(alpha);
N=input('Input number of panels: ');
tic
%-----Part 1---
%generate the points on the panels and creating 4 arrays-
%start points and endpoints of panel ,
%beta-> the angle of panel to horizontal and
%midpoints of panel
[x,z]=panelgen(naca,N,alpha);
startpoints=[x,z];
startpoints(N+2,:)=[];
endpoints=[x,z];
endpoints(1,:)=[];
beta=atan2((endpoints(:,2)-startpoints(:,2)),(endpoints(:,1)-startpoints(:,1)));
midpoints=(startpoints+endpoints)/2;

%----Part2----
%creating N+1 equations with N+1 unknowns
%equations are stored in matrix A
%the solution is stored in matrix B
%preallocating the matrix of A and B
B(1:N+1,1)=0;
A(N+1,N+1)=0;
%generate the matrix A and B by getting the components of velocity,u and v,
%using the function cdoublet. this finds the induced velocity by other
%panels
for i=1:N
    for j=1:N+1
        [u,v]=cdoublet(midpoints(i,:),startpoints(j,:),endpoints(j,:));
        A(i,j)=v*cos(beta(i))-u*sin(beta(i)) ;
    end
    B(i)=-Uinf*sin(alpha-beta(i));
end 
%by the kutta condition
B(N+1)=0;
A(N+1,[1 N N+1])=[1 -1 1];
%The N+1 eqns and solutions are complete now solve eqn
strength=A\B;

%-----Part 3----Creating the velocity vector plot
%---part 3.1
%finding the velocity field ard the airfoil
%creating a grid ard the field and use cdoublet once again to find the
%velocity components induced by the airfoil
%creating a grid
[X,Y] = meshgrid(-.2:.15:1.2,-.7:.15:.7);
[sizex,sizey]=size(X);
Ugrid=0.*X;
Vgrid=0.*Y;
%check if the points are in the airfoil if so the velocity component =0
[in,on]=inpolygon(X,Y,x,z);
for i=1:sizex
    for j=1:sizey
        if in(i,j)==1 ||on(i,j)==1
            Ugrid(i,j)=0;
            Vgrid(i,j)=0;
        else
            %calculating the velocity component of the field using the
            %formula given in handout
            for count=1:N+1
                [utemp,vtemp]=cdoublet([X(i,j),Y(i,j)],startpoints(count,:),endpoints(count,:));
                Ugrid(i,j)=Ugrid(i,j)+strength(count)*utemp;
                Vgrid(i,j)=Vgrid(i,j)+strength(count)*vtemp;
            end
            Ugrid(i,j)=Uinf*cos(alpha)+Ugrid(i,j);
            Vgrid(i,j)=Uinf*sin(alpha)+Vgrid(i,j);
        end
    end
end
%part3.2
%generating the velocity vector plot
figure
quiver(X(~in),Y(~in),Ugrid(~in),Vgrid(~in));
hold on
plot(startpoints(:,1),startpoints(:,2),'r');
hold off

%----part 4-- plot the streamline
%part 4.1- generate data for streamlineplot
% plot streamlines needs much finer mesh 
%mesh seperated into three parts its much finer in the middle 
gridx1=[-.2:.05:0, 0.05:0.01:1.1, 1.15:.05:1.2];
gridy1=[-.7:.05:-0.25, -.2:0.01:.3, .35:.05:0.7];
[X1,Y1] = meshgrid(gridx1,gridy1);
[sizex1,sizey1]=size(X1);U1grid=0.*X1;
V1grid=0.*Y1;
[in1,on1]=inpolygon(X1,Y1,x,z);
% put the mesh into c doublet to obtain the velocity field
for i=1:sizex1
    for j=1:sizey1
        if in1(i,j)==1||on1(i,j)==1
            U1grid(i,j)=0;
            V1grid(i,j)=0;
        else
            for count=1:N+1
                [u1temp,v1temp]=cdoublet([X1(i,j),Y1(i,j)],startpoints(count,:),endpoints(count,:));
                U1grid(i,j)=U1grid(i,j)+strength(count)*u1temp;
                V1grid(i,j)=V1grid(i,j)+strength(count)*v1temp;
            end
            U1grid(i,j)=Uinf*cos(alpha)+U1grid(i,j);
            V1grid(i,j)=Uinf*sin(alpha)+V1grid(i,j);
        end
    end
end
%part 4.2 plot the streamline
figure
streamslice(X1,Y1,U1grid,V1grid);
hold on
plot(startpoints(:,1),startpoints(:,2),'r');

%-----part 5 calculating the C_L
Cl=-2*strength(N+1)/Uinf;
toc
fprintf('%s %4.3f \n','The coefficient of lift is ',Cl)
%end of script