pkg install datatypes;
pkg install miscellaneous;
pkg install statistics;
pkg install symbolic;

% Simple Octave speed test

disp("Starting speed test...");

tic;

% Test 1: Matrix multiplication
A = rand(1000);
B = rand(1000);
C = A * B;

% Test 2: Loop computation
s = 0;
for i = 1:1e7
    s = s + i;
end

% Test 3: Element-wise operations
x = rand(1e6, 1);
y = sin(x) + cos(x).^2;

elapsed_time = toc;

printf("Done!\nTotal time: %.3f seconds\n", elapsed_time);
