%{
Function that propagates a electromagnetic field in a medium for a certain length and returns
the resulting field at the length, by taking the each point in the object
plane as a plane wave and propagating the angular spectrum

-----------------Input---------------------
E1 =  the electromagnetic field right before propagation,
L = length of propagation in meters,
delta_image = Sample distance at the image plane,
wavelength = wavelength of the wave, set to be in the middle of the visible
spectrum,
refractive_index = The refractive index of the medium that the field will
be propagated through.

-----------------Output--------------------
E2 = The resulting electromagnetic field after propagation of the first
fields angular spectrum.

----------------Declared variables---------
matrix_size = size of matrix, global variable,
delta_k = sampling distance in the k plane at distance L,
k_x = A vector with all the sample positions in axial direction of kx,
k_y = Is equal to k_x to make the plane into a square form and so all
matrixes is the same size,
kx_matrix = Contains the x-components of the k vector in plane k,
ky_matrix = Contains the y-components of the k vector in plane k,
k_length = length of the k vector as function of wavelength and refractive
index,
kz_matrix = The z-component of the k vector for every plane wave in the k
plane,
phase_propagation = Every plane wave in the k plane is multiplied with this
as it propagates the length L,
Angular_spectrum_plane_1 = The angular spectrum of the plane wave in plane 1, the
object plane,
Angular_spectrum_plane_2 = The resulting angular spectrum in plane 2, often
image plane, after propagation of length L.

------------------Functions---------------
fft2c = fast fourier transform of the field and returns it as a complex
matrix,
ifft2c = inverse fast fourier transform of the angular spectrum and returns
it as a complex matrix.
%}

function E2=Angular_propagation(E1,L,delta_image,wavelength,refractive_index)
global matrix_size
% Calculate sampling distance in k-plane, the same way as in the main
% files, also generates k-vector and the k-matrix.
delta_k=2*pi/(matrix_size*delta_image); 
k_x=-matrix_size/2*delta_k:delta_k:(matrix_size/2-1)*delta_k;
k_y=k_x;
[kx_matrix,ky_matrix]=meshgrid(k_x,k_y); 
length_k=2*pi/(wavelength/refractive_index); 
kz_matrix=sqrt(length_k^2-kx_matrix.^2-ky_matrix.^2); 

% Calculate the phase and the angular spectrum before and after propagation
% of length L.
phase_propagation=exp(1i*kz_matrix*L); 
Angular_spectrum_plane_1=delta_image^2/(2*pi)^2*shifted_FFT2(E1); 
Angular_spectrum_plane_2=Angular_spectrum_plane_1.*phase_propagation;

% Calculate the electric field by propagating the angular spectrum.
E2=delta_k^2*matrix_size^2*shifted_IFFT2(Angular_spectrum_plane_2);
