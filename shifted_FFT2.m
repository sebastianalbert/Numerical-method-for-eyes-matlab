%{
This function takes the input and first swaps the first and third
    quadrants and the second and fourth quadrants since the fourier
    transform needs its input to be shifted. Then it transforms it with 2D
    fourier transform and shifts it again before returning it as a complex
    N X N matrix.
---------------------------------------------------------------------------
Input:
matrix = input, in this case the electric field, as a double N X N matrix.
---------------------------------------------------------------------------
Output:
FFT = the 2D fourier transform of the input matrix, as a N X N complex
matrix.
%}
function FFT=shifted_FFT2(matrix)
FFT=fftshift(fft2(fftshift(matrix)));