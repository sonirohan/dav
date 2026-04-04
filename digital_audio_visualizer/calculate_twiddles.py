import math

def generate_twiddles(n, filename="./digital_audio_visualizer/twiddle_defs.txt"):
    # Standard Q15 scaling for 16-bit fixed-point math.
    # Scales [-1.0, 1.0] sine/cosine waves to [-32767, 32767].
    SCALE = (1 << 15) - 1 

    # Open the file for writing
    with open(filename, 'w') as f:
        print(f"// --- {n}-Point FFT Twiddle Factors ---", file=f)
        print(f"// Formula: W_n^k = cos(2*pi*k/n) - j*sin(2*pi*k/n)", file=f)
        print(f"// Format: Hex (Upper half: Real, Lower half: Imaginary)", file=f)
        print(f"// Scaling: Q15 Format (Multiplied by {SCALE})\n", file=f)

        # A standard radix-2 DIT FFT only requires n/2 twiddle factors
        num_factors = n // 2 

        definitions = []

        for k in range(num_factors):
            # Calculate the base angle: 2 * pi * k / n
            theta = 2.0 * math.pi * k / n
            
            # Calculate real (cos) and imaginary (-sin) parts
            real = math.cos(theta)
            imag = -math.sin(theta) 
            
            # Apply scaling and round to nearest integer
            real_scaled = int(round(real * SCALE))
            imag_scaled = int(round(imag * SCALE))
            
            # Mask to 16-bit two's complement
            real_hex = real_scaled & 0xFFFF
            imag_hex = imag_scaled & 0xFFFF
            
            # Concatenate: (Real << 16) OR Imaginary
            packed_32bit = (real_hex << 16) | imag_hex
            
            # Write the copy-pasteable SystemVerilog localparam to the file
            definitions.append(
                f"localparam logic [WIDTH-1:0] bfu_w_{k}_{n} = 32'h{packed_32bit:08X};"
            )

        for index in range(0, len(definitions), 4):
            print(" ".join(definitions[index:index + 4]), file=f)
            
    # Print a confirmation to the console
    print(f"Successfully generated {n}-point twiddle factors and saved to {filename}")

# Change this value to 128 to generate 128-point twiddle factors
generate_twiddles(64)