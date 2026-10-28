import math
import struct
import wave
from pathlib import Path

path = Path(__file__).resolve().parent / "assets" / "tick.wav"
rate = 22050
samples = []
for n in range(int(rate * 0.105)):
    t = n / rate
    envelope = (1 - t / 0.105) ** 3
    tone = math.sin(2 * math.pi * (570 - 190 * t / 0.105) * t)
    samples.append(int(11000 * envelope * tone))
with wave.open(str(path), "wb") as out:
    out.setnchannels(1)
    out.setsampwidth(2)
    out.setframerate(rate)
    out.writeframes(struct.pack("<" + "h" * len(samples), *samples))
print(path)
