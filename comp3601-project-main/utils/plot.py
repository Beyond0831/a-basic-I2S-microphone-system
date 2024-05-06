import csv
import math
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation

BLOCKSIZE = 128
CLIP = 8

with open("frames.txt") as f:
    reader = csv.reader(f, delimiter = ',')
    data = [(int(row[0]), int(row[1])) for row in reader]

fig, ax = plt.subplots()
ax.set_xlim(left=0, right=BLOCKSIZE - CLIP)
ax.plot(data)

def animate(i):
    start = i * BLOCKSIZE
    end = i * BLOCKSIZE + BLOCKSIZE - CLIP
    ax.set_xlim(left=start, right=end)

ani = FuncAnimation(fig, animate, frames=(math.ceil(len(data) / BLOCKSIZE)), interval=200, repeat=False)
plt.show()