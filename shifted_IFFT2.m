%{
This function takes the input and first swaps the first and third
    quadrants and the second and fourth quadrants since the fourier
    transform needs its input to be shifted. Then it transforms it with 2D
    inverse fourier transform and shifts it again before returning it as a 
    complex N X N matrix.
---------------------------------------------------------------------------
Input:

matrix = input, in this case the electric field, as a double N X N matrix.

---------------------------------------------------------------------------
Output:

IFFT = the 2D inverse fourier transform of the input matrix, as a N X N complex
matrix.

%}
function IFFT=shifted_IFFT2(matrix)
IFFT=fftshift(ifft2(fftshift(matrix)));