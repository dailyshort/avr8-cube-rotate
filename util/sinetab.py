import math

print("    .balign 256")
print("sintab:")
for row in range(0, 256, 16):
    vals = [round(127 * math.sin(2 * math.pi * i / 256)) for i in range(row, row + 16)]
    print("    .byte " + ", ".join(str(v & 0xFF) for v in vals))

D = 110
print("    .balign 256")
print("persp:")
for row in range(0, 128, 16):
    vals = []
    for i in range(row, row + 16):
        z = i - 64                        # table index = z + 64
        vals.append(min(127, round(64 * D / (D - z))))
    print("    .byte " + ", ".join(map(str, vals)))
