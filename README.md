# The Conversation - an interactive site-specific installation

Software part of an art installation exhibited in May 2015 in Prague. Requires two devices running Processing, two Arduinos running standard firmata for Processing, a bunch of photo resistors and a laser module.

## sender.pde
1. Downloads the latest captured image from Flickr according to camera metadata,
1. converts it into a 64 px wide black and white image,
1. converts the image data into a continuous stream of binary data (black: 1, white: 0),
1. streams it through switching the Arduino-mounted laser on and off at 20bps.

## receiver.pde
1. Reads data from the photo resistors that receive the laser light
1. decodes resistance levels into binary
1. paints the received data on the screen, pixel by pixel
1. sends the overflowing lines to `receiver_upper.pde`

## receiver_upper.pde
1. receives overflowing lines from `receiver.pde`
1. paints them on a 2nd screen as they move off from the first
