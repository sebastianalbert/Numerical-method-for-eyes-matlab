%{
This file is one the main files and is based on the Gullstrand-Emsley model.
 It is divided into several sections for easier manipulation of data. 

In the first section we calculate all the necessary constants and the
starting E-field. First we create a object which will contain all the
information about the lenses and can be called from other places to get the
focal length of the said lens. The total power of the lens can either be
calculated by using the radius of curvator of the front and the back or by
using the already know power of those.

Then it is possible to define the sampling distance in the image plane, by
using the systems total magnification, and generate two vectors with all
the sample points in both x- and y-direction. From this information we can
create the incident E-field by using the formula, e^(j*k*r)/r.

In the second section we calculate the field after propagation with the
beam propagation method and the propagation of angular spectrum method. See
the Angular_propagation.m and the BPM_Gullstrand_Emsley.m files for further 
information about those methods. 

In the third section we plot the intensitety distribution along
the direction of propagation by taking the y-values from the intensity
matrix and plotting it against the distance the field has propagated.

In the fourth section we calculate the PSF, which is just "abs(E)^2", and
the image by taking the convultion of the object matrix and the PSF. The
image in the image plane, on the retina, can be compared with the image in
the object plane by plotting them both which is also done in this section.

In the fifth section we plot the intensity, the magnitude and
the phase shift of the field in the image plane, on the retina.

In the last section we calculate different errors by using the Image
processing tool provided by MATLAB.

%}
%% Calculate necessary constants and starting field
close all
clc

global matrix_size
load Intensity_matrix

L=5;    % Propagation length in meters
wavelength=550e-9;
refractive_index_air=1;
matrix_size=2048;     % Matrix size of the object
delta_object=100e-2/matrix_size; % Sampling distance in the object plane

% Different method, uses radius of curvature.
%Lens(1) = Lenses(7.259e-3, -5.585e-3, 1, 1.376, 0);
%Lens(2) = Lenses(8.672e-3, -6.328e-3, 1.336, 1.406, 4.979e-3);

% Current method, uses optical power.
Lens(1) = Lenses(43.1, 0, 1, 1, 0);
Lens(2) = Lenses(7.82, 13.3, 1.336, 1.422, 3.7e-3);

% Focal length
Lens(1).focal = 1/get_power(Lens(1));
Lens(2).focal = 1/get_power(Lens(2));

% Calculates the total magnification of the lens system
p(1)=-L; p(2)=3.6e-3;
for i=1:length(p)
    if i==1
        p(i)=p(i);
    else
        p(i)=p(i)-q(i-1);
    end
    q(i)=1./(1./Lens(i).focal-1./p(i));
    m(i)=(-1).*q(i)/p(i);
end

M=-1*prod(m); % Total magnification

delta_image=M.*delta_object; % Sampling distance in the image plane

% Declaration of vectors in the image plane
x_vector=-matrix_size/2*delta_image:delta_image:(matrix_size/2-1)*delta_image;
y_vector=x_vector;
[x_matrix,y_matrix]=meshgrid(x_vector,y_vector); 
r_matrix=sqrt(x_matrix.^2+y_matrix.^2);

% Wavenumber
k0=2*pi*refractive_index_air/wavelength;
r_k_plane=sqrt(L^2-(x_matrix).^2-(y_matrix).^2);

% Constants for the lenses/parts of the eye
pupil_diameter=4e-3;
TF_pupil=r_matrix<(pupil_diameter/2);
k(1)=(2*pi*1.3771)/(632.8e-9/1.3771);
k(2)=2*pi*1.42/(632.8e-9/1.42);

% Gets the transmission functions for all the lenses
for i=1:length(Lens)
    Lens(i).TF=get_TF(k(i),r_matrix,Lens(i));
end

% Calculates the incident E-field
E_in=exp(1i*k0*r_k_plane)./r_k_plane;
L=24e-3;
delta_z=0.1e-3;
L_vector=0:delta_z:L;

%% Calculation of the electrical field with BPM

E1=E_in;
I_norm=zeros(matrix_size,length(L_vector));
step_number=0;

% Calculates the E-field with BPM
for current_L=L_vector
    step_number=step_number+1;
    
    E2=BPM_Gullstrand_Emsley(E1,delta_z,delta_image,wavelength, current_L, Lens, TF_pupil);
    E_y=E2(:,matrix_size/2+1);
    I_y=abs(E_y).^2;
    I_y_norm=I_y/max(I_y);
    I_norm(:,step_number)=I_y_norm;
        
    E1=E2;
end

%%
figure(11)
imagesc(L_vector*1e3,y_vector*1e3,I_norm/max(max(I_norm))*64)
title('       Intensity distribution along the propagation direction', 'Fontsize',14)
set(gca,'FontSize',14)
yticks([-2 -1 0 1 2])
xticks([0 6 12 18 24])
xlabel('z [mm]')
ylabel('y [mm]')
colorbar
colormap('jet');
%pause

%%
PSF=abs(E2).^2;
Image=shifted_IFFT2(shifted_FFT2(B).*shifted_FFT2(PSF));

figure('Name','Plane 2, Retina','NumberTitle','off')
%image(xvekt*1e3*delta_b,yvekt*1e3*delta_b,PSF/max(max(PSF))*64)
image(x_vector*1e3*delta_image,y_vector*1e3*delta_image,Image/max(max(Image))*64)
colormap(gray)
figure('Name','Plane 1, Eye Chart','NumberTitle','off')
image(x_vector*1e3*delta_image,y_vector*1e3*delta_image,B/max(max(B))*64)
colormap(gray)

%% plot intensity, phase and mag
figure(1)
plot(x_vector,PSF(matrix_size/2+1,:)/max(PSF(matrix_size/2+1,:)));
axis([-1e-3 1e-3 0 1])
set(gca,'FontSize',14)
yticks([0 0.5 1])
xticks([-1e-3 0 1e-3])
xlabel('x (m)'); ylabel('Intensity');
title(['Intensity distribution in the image plane']);

figure(2)
%plot obs field mag
plot(x_vector,abs(E2(matrix_size/2+1,:)));
xlabel('x (m)'); ylabel('Magnitude');
title(['Magnitude in the image plane']);

figure(3)
%plot obs field phase
plot(x_vector,unwrap(angle(E2(matrix_size/2+1,:))));
xlabel('x (m)'); ylabel('Fas (rad)');
title(['E-field phase distribution in the image plane']);

%% Calculate a number of different errors
err1 = immse(Image/max(max(Image))*64, B/max(max(B))*64);
fprintf('\n The mean-squared error is %0.4f\n', err1);
K = imabsdiff(Image/max(max(Image))*64, B/max(max(B))*64);
[ssimval, ssimmap] = ssim(Image/max(max(Image))*64,B/max(max(B))*64);
fprintf('\n The SSIM value is %0.4f.\n',ssimval);
[peaksnr, snr] = psnr(Image/max(max(Image))*64,B/max(max(B))*64);
fprintf('\n The Peak-SNR value is %0.4f \n', peaksnr);
fprintf('\n The SNR value is %0.4f \n', snr);