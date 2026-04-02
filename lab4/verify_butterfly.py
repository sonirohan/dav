import re
import sys
import os
import subprocess

def parse_hex_to_complex(hex_str):
    """Converts a 32-bit hex string into a Python complex number (16-bit signed real/imag)."""
    val = int(hex_str, 16)
    real = (val >> 16) & 0xFFFF
    imag = val & 0xFFFF
    
    # Sign extension for 16-bit two's complement
    if real >= 0x8000: real -= 0x10000
    if imag >= 0x8000: imag -= 0x10000
        
    return complex(real, imag)

def complex_to_hex(c):
    """Converts a Python complex number back to a 32-bit hex string with 16-bit wrapping."""
    real = int(c.real) & 0xFFFF
    imag = int(c.imag) & 0xFFFF
    return f"{(real << 16) | imag:08x}"

def format_complex_str(c):
    """Formats an integer complex number into a clean string, e.g., '150+200j'"""
    real = int(c.real)
    imag = int(c.imag)
    sign = '+' if imag >= 0 else ''
    return f"{real}{sign}{imag}j"

def format_float_complex_str(c):
    """Formats a float complex number (for the unscaled W) into a clean string, e.g., '0.707-0.707j'"""
    real = c.real
    imag = c.imag
    sign = '+' if imag >= 0 else ''
    return f"{real}{sign}{imag}j"

def is_within_1_percent(actual_c, expected_c):
    """Checks if the actual complex output is within a 1% tolerance of the expected."""
    real_error = abs(actual_c.real - expected_c.real)
    imag_error = abs(actual_c.imag - expected_c.imag)
    
    # Calculate 1% of the expected magnitude. 
    # We use max(2.0, ...) as an absolute tolerance to allow for off-by-one 
    # hardware truncation rounding when the expected values are very close to 0.
    real_allowed = max(2.0, 0.01 * abs(expected_c.real))
    imag_allowed = max(2.0, 0.01 * abs(expected_c.imag))
    
    return real_error <= real_allowed and imag_error <= imag_allowed

def compute_expected_via_pycalc(a_c, b_c, w_c):
    """Calls py_calc.py to compute the expected answers, returning the expected complex objects."""
    
    # 1. Unscale W back to a magnitude of <= 1 (unit circle)
    w_unscaled = complex(w_c.real / 32768.0, w_c.imag / 32768.0)
    
    # 2. Format inputs as clean strings expected by py_calc.py
    a_str_in = format_complex_str(a_c)
    b_str_in = format_complex_str(b_c)
    w_str_in = format_float_complex_str(w_unscaled) # Keeps the decimals!
    
    input_data = f"{a_str_in}\n{b_str_in}\n{w_str_in}\n"
    
    result = subprocess.run(
        [sys.executable, 'lab4/py_calc.py'], 
        input=input_data, 
        text=True, 
        capture_output=True
    )
    
    if result.returncode != 0:
        print(f"Error calling lab4/py_calc.py:\n{result.stderr}")
        sys.exit(1)

    stdout = result.stdout

    try:
        add_str = re.search(r'A\+BW\s*=\s*(.+)', stdout).group(1).strip()
        sub_str = re.search(r'A-BW\s*=\s*(.+)', stdout).group(1).strip()
    except AttributeError:
        print("Error: Could not parse output from lab4/py_calc.py. Check its print formatting.")
        sys.exit(1)

    # Clean the outputs by removing any spaces or parentheses before parsing
    add_clean = add_str.replace(' ', '').strip('()')
    sub_clean = sub_str.replace(' ', '').strip('()')

    # Return the pure complex objects (so we can run math on them for the 1% check)
    return complex(add_clean), complex(sub_clean)

def main():
    log_filename = "lab4/test_butterfly_output.txt"
    calc_filename = "lab4/py_calc.py"
    
    if not os.path.exists(log_filename):
        print(f"Error: Please create '{log_filename}' and paste your testbench output into it.")
        sys.exit(1)
        
    if not os.path.exists(calc_filename):
        print(f"Error: '{calc_filename}' not found in the current directory.")
        sys.exit(1)

    with open(log_filename, 'r') as f:
        log_text = f.read()

    pattern = re.compile(
        r"a=([0-9a-fA-F]+)\s+b=([0-9a-fA-F]+)\s+w=([0-9a-fA-F]+)\s+\|\s+out1=([0-9a-fA-F]+)\s+out2=([0-9a-fA-F]+)"
    )

    test_cases = []
    all_actual_outputs = []

    for line in log_text.strip().split('\n'):
        match = pattern.search(line)
        if match:
            a_hex, b_hex, w_hex, o1_hex, o2_hex = match.groups()
            
            # Skip empty initialization states
            if a_hex == '00000000' and b_hex == '00000000' and w_hex == '00000000':
                continue 

            all_actual_outputs.append((o1_hex, o2_hex))

            # Record unique inputs chronologically and track the last seen output for them
            if not test_cases or test_cases[-1]['a'] != a_hex or test_cases[-1]['b'] != b_hex or test_cases[-1]['w'] != w_hex:
                test_cases.append({
                    'a': a_hex, 'b': b_hex, 'w': w_hex, 
                    'last_o1': o1_hex, 'last_o2': o2_hex
                })
            else:
                test_cases[-1]['last_o1'] = o1_hex
                test_cases[-1]['last_o2'] = o2_hex

    print(f"Found {len(test_cases)} unique test cases. Verifying via py_calc.py...\n" + "-"*85)
    
    for i, tc in enumerate(test_cases):
        a_c = parse_hex_to_complex(tc['a'])
        b_c = parse_hex_to_complex(tc['b'])
        w_c = parse_hex_to_complex(tc['w'])

        # Let py_calc.py do the math (now returns the complex objects directly)
        exp_add_c, exp_sub_c = compute_expected_via_pycalc(a_c, b_c, w_c)

        passed = False
        match_o1_hex = None
        match_o2_hex = None
        
        # Look through all outputs chronologically for a match within 1%
        for o1_hex, o2_hex in all_actual_outputs:
            actual_o1_c = parse_hex_to_complex(o1_hex)
            actual_o2_c = parse_hex_to_complex(o2_hex)
            
            if is_within_1_percent(actual_o1_c, exp_add_c) and is_within_1_percent(actual_o2_c, exp_sub_c):
                passed = True
                match_o1_hex = o1_hex
                match_o2_hex = o2_hex
                break

        # Format inputs for printing (we print the original scaled W for hardware context)
        a_str = format_complex_str(a_c)
        b_str = format_complex_str(b_c)
        w_str = format_complex_str(w_c)
        exp_out1_str = format_complex_str(exp_add_c)
        exp_out2_str = format_complex_str(exp_sub_c)

        if passed:
            tb_out1_str = format_complex_str(parse_hex_to_complex(match_o1_hex))
            tb_out2_str = format_complex_str(parse_hex_to_complex(match_o2_hex))
            
            print(f"✅ Testcase {i+1} [PASS (~1% tol)]: a={a_str}, b={b_str}, w={w_str} (HW Scaled)")
            print(f"    -> Expected exactly : out1={exp_out1_str}, out2={exp_out2_str}")
            print(f"    -> Testbench Output : out1={tb_out1_str}, out2={tb_out2_str}\n")
        else:
            tb_out1_str = format_complex_str(parse_hex_to_complex(tc['last_o1']))
            tb_out2_str = format_complex_str(parse_hex_to_complex(tc['last_o2']))
            
            print(f"❌ Testcase {i+1} [FAIL]: a={a_str}, b={b_str}, w={w_str} (HW Scaled)")
            print(f"    -> Expected exactly : out1={exp_out1_str}, out2={exp_out2_str}")
            print(f"    -> Testbench Output : out1={tb_out1_str}, out2={tb_out2_str} (recorded from end of input cycle)\n")

if __name__ == "__main__":
    main()