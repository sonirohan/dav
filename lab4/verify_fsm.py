import re

# 1. Define the inputs driven in the testbench
inputs = [
    # TC1: Lab 4 Spec Input: 10, 15, 20, 25 (scaled to fit in 32 bits)
    (0x000a0000, 0x000f0000, 0x00140000, 0x00190000),
    # TC2: Simple impulse
    (0x00000001, 0x00000000, 0x00000000, 0x00000000),
    # TC3: Step input
    (0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF),
    # TC4: Ramp input
    (0x00000000, 0x00000001, 0x00000002, 0x00000003),
    # TC5: Sinusoidal input
    (0x00007FFF, 0x0000B504, 0x0000D504, 0x0000E504),
    # TC6: Random input
    (0x12345678, 0x9ABCDEF0, 0x0F0F0F0F, 0xF0F0F0F0)
]

# Raw output copied from your simulation console
sim_output_text = """
Starting Testcase 0: Driving new sample
Output A: 00430000
Output B: fff70009
Output C: fff70000
Output D: fff7fff7
Starting Testcase 1: Driving new sample
Output A: 00000001
Output B: 00000001
Output C: 00000001
Output D: 00000001
Starting Testcase 2: Driving new sample
Output A: fffcfffc
Output B: 00000000
Output C: 00000000
Output D: 00000000
Starting Testcase 3: Driving new sample
Output A: 00000003
Output B: ffffffff
Output C: 0000ffff
Output D: 0001ffff
Starting Testcase 4: Driving new sample
Output A: 0000ef0b
Output B: d000aafb
Output C: 0000bafb
Output D: 3000aafb
Starting Testcase 5: Driving new sample
Output A: acee3566
Output B: f1269d9e
Output C: 959695a6
Output D: 1526f136
"""

# --- Fixed-Point Datapath Modeling ---

def to_signed_16(val):
    """Converts a 16-bit integer to a signed Python integer."""
    val = val & 0xFFFF
    return val - 0x10000 if val >= 0x8000 else val

def hex_to_complex(hex_val):
    """Splits a 32-bit hex into a complex number (Top 16b = Real, Bottom 16b = Imag)."""
    real = to_signed_16(hex_val >> 16)
    imag = to_signed_16(hex_val & 0xFFFF)
    return complex(real, imag)

def complex_to_hex(cplx):
    """Packs a complex number back into a 32-bit hex string."""
    re = int(cplx.real) & 0xFFFF
    im = int(cplx.imag) & 0xFFFF
    return f"{(re << 16) | im:08x}"

def mult_q15(a_cplx, w_cplx):
    """Models the 16-bit hardware multiplication and 15-bit truncation."""
    a_re, a_im = int(a_cplx.real), int(a_cplx.imag)
    w_re, w_im = int(w_cplx.real), int(w_cplx.imag)
    
    # Matches hardware logic: multiply, subtract/add, then right shift by 15
    re_part = (a_re * w_re - a_im * w_im) >> 15
    im_part = (a_re * w_im + a_im * w_re) >> 15
    return complex(re_part, im_part)

def bfu(a, b, w):
    """Hardware Butterfly Unit Model."""
    bw = mult_q15(b, w)
    return a + bw, a - bw

def hardware_fft_4point(a_hex, b_hex, c_hex, d_hex):
    """Recreates the exact datapath of the SystemVerilog FSM."""
    a = hex_to_complex(a_hex)
    b = hex_to_complex(b_hex)
    c = hex_to_complex(c_hex)
    d = hex_to_complex(d_hex)
    
    # Twiddle factors derived from your SV parameters
    w0 = complex(32767, 0)      # 32'h7FFF0000
    w1 = complex(0, -32768)     # 32'h00008000
    
    # Stage 1
    mid0, mid1 = bfu(a, c, w0)
    mid2, mid3 = bfu(b, d, w0)
    
    # Stage 2
    out_a, out_c = bfu(mid0, mid2, w0)
    out_b, out_d = bfu(mid1, mid3, w1)
    
    return [
        complex_to_hex(out_a),
        complex_to_hex(out_b),
        complex_to_hex(out_c),
        complex_to_hex(out_d)
    ]

# --- Parsing and Verification Logic ---

def parse_sim_output(text):
    """Extracts the output values from the Verilog display log."""
    results = {}
    current_case = -1
    
    for line in text.strip().split('\n'):
        if "Starting Testcase" in line:
            current_case = int(re.search(r'\d+', line).group())
            results[current_case] = []
        elif "Output" in line:
            hex_val = line.split(": ")[1].strip()
            results[current_case].append(hex_val)
            
    return results

def run_verification():
    sim_results = parse_sim_output(sim_output_text)
    
    all_passed = True
    print("========================================")
    print("      HARDWARE VERIFICATION REPORT      ")
    print("========================================\n")
    
    for idx, input_set in enumerate(inputs):
        print(f"--- Validating Testcase {idx} ---")
        
        # Calculate bit-accurate expected results
        expected_hex = hardware_fft_4point(*input_set)
        
        # Grab actual simulation results
        actual_hex = sim_results.get(idx, ["ERROR", "ERROR", "ERROR", "ERROR"])
        
        passed = True
        for i, (exp, act) in enumerate(zip(expected_hex, actual_hex)):
            match = exp == act
            if not match: passed = False
            
            letter = chr(65 + i) # A, B, C, D
            status = "[PASS]" if match else "[FAIL]"
            print(f"  Out {letter} | Expected: {exp} | Actual: {act} | {status}")
            
        if passed:
            print("  >> RESULT: PERFECT MATCH\n")
        else:
            print("  >> RESULT: MISMATCH DETECTED\n")
            all_passed = False

    print("========================================")
    if all_passed:
        print(" VERIFICATION SUCCESS: All hardware math is correct.")
    else:
        print(" VERIFICATION FAILED: Check the mismatches above.")
    print("========================================")

if __name__ == "__main__":
    run_verification()