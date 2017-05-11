r=linspace(-4,4,100000);
%r=0;
z=linspace(0,3.69,100000);

refractive_index_formula=1.368-0.0022649*r.^2-0.000119*r.^4+0.053451*z-0.018438*z.^2+0.000745*z.^3+0.00009*z.^4;

plot(r,refractive_index_formula)
xlabel('Radiella avståndet, mm')
ylabel('Brytningsindex')
