import sympy as sp
import math

def solve_audio_level_shifter():
    print("--- MAX9814 Audio Level Shifter Solver ---\n")
    
    # 1. Define targets
    V_in_ac = 0.75
    V_out_ac = 0.5
    V_bias = 3.3
    V_out_dc = 0.5
    
    # 2. Resistor Calculations
    R2_choice = 33000  # 33k Ohms
    R3_val = 5.6 * R2_choice 
    Rp_val = (R2_choice * R3_val) / (R2_choice + R3_val)
    R1_val = 0.5 * Rp_val
    
    print(f"1. RESISTOR VALUES:")
    print(f"   R2 = {R2_choice/1000:.1f} kΩ")
    print(f"   R3 = {R3_val/1000:.1f} kΩ")
    print(f"   R1 = {R1_val/1000:.1f} kΩ\n")
    
    # 3. Audio Capacitor Sizing
    f_signal_lowest = 20.0 # 20 Hz (Lowest frequency of interest for full audio)
    f_cutoff = f_signal_lowest / 10.0 # Target 2 Hz cutoff for zero attenuation
    
    R_total_ac = R1_val + Rp_val
    
    # fc = 1 / (2 * pi * R * C)
    C_min = 1 / (2 * math.pi * f_cutoff * R_total_ac)
    
    print("2. CAPACITOR SIZING (For MAX9814 Audio):")
    print(f"   Lowest Signal Frequency: {f_signal_lowest} Hz")
    print(f"   Target Cutoff (fc): <= {f_cutoff} Hz")
    print(f"   Calculated Minimum C1 = {C_min * 1e6:.2f} µF")
    
    # Standard value recommendation
    standard_c = 2.2 # Next common standard value up from calculated minimum
    actual_fc = 1 / (2 * math.pi * (standard_c * 1e-6) * R_total_ac)
    print(f"\n   Recommendation: Use a standard {standard_c} µF capacitor.")
    print(f"   This will give you a real-world cutoff frequency of {actual_fc:.2f} Hz.")

if __name__ == "__main__":
    solve_audio_level_shifter()