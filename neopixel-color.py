# Set a NeoPixel to a color specified in the environment, and blink it.

import time
import board
import os
import sys

# Set the appropriate neopixel count for your pixel strip
NUM_PIXELS = 1

# Get configuration from the environment, or set a default value if not there
def get_from_env(v, d):
  if v in os.environ and '' != os.environ[v]:
    return os.environ[v]
  else:
    return d
HZN_ARCH = get_from_env('HZN_ARCH', '')
ARCH = get_from_env('ARCH', HZN_ARCH)
if ARCH == '':
  print("%s: ARCH or HZN_ARCH must be set in the environment." % (sys.argv[0]))
  sys.exit(1)
NEOPIXEL_COLOR = get_from_env('NEOPIXEL_COLOR', '#0000FF')
SECONDS_ON = get_from_env('SECONDS_ON', '3.5')
SECONDS_OFF = get_from_env('SECONDS_OFF', '0.25')

# Convert the environment variables to the right types or fallback on defaults
try:
  red = int(NEOPIXEL_COLOR[1:3], 16)
  green = int(NEOPIXEL_COLOR[3:5], 16)
  blue = int(NEOPIXEL_COLOR[5:7], 16)
  seconds_on = float(SECONDS_ON)
  seconds_off = float(SECONDS_OFF)
  print("%s: configured: color=(%d,%d,%d), on=%0.2f, off=%0.2f" % \
    (sys.argv[0], red, green, blue, seconds_on, seconds_off))
except:
  print("%s: configuration error: Color=\"%s\", On=\"%s\", Off=\"%s\"" % \
    (sys.argv[0], NEOPIXEL_COLOR, SECONDS_ON, SECONDS_OFF))
  red = 0
  green = 0
  blue = 255
  seconds_on = 3.5
  seconds_off = 0.25
  print("%s: using defaults: color=(%d,%d,%d), on=%0.2f, off=%0.2f" % \
    (sys.argv[0], red, green, blue, seconds_on, seconds_off))

# Create the color 3-tuple from the converted values
color = (red, green, blue)

# Different libraries for Raspberry Pi and NVIDIA Jetson
if ARCH == 'arm64':
  # NVIDIA Jetson device with SPI0 enabled and with the Neopixel control wire
  # attached to Jetson GPIO pin 19 (SPI0 MOSI)
  import busio
  import neopixel_spi as neopixel
  spi = board.SPI()
  PIXEL_ORDER = neopixel.GRB
  pixels = neopixel.NeoPixel_SPI(spi, NUM_PIXELS, pixel_order=PIXEL_ORDER, auto_write=False)
elif ARCH == 'arm':
  # Raspberry Pi with NeoPixel control wire attached to Pi GPIO board.D18
  import neopixel
  RASPBERRY_PI_GPIO = board.D18
  pixels = neopixel.NeoPixel(RASPBERRY_PI_GPIO, NUM_PIXELS)
else:
  print("%s: unsupported architecture: \"%s\"" % (sys.argv[0], ARCH))
  sys.exit(1)

# Loop forever displaying the color, then turning the neopixel off
while True:
  pixels[0] = color
  pixels.show()
  time.sleep(seconds_on)
  pixels[0] = (0, 0, 0)
  pixels.show()
  time.sleep(seconds_off)

