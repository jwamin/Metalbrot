![Screenshot](readme-assets/mbrot.png "Metalbrot-macos")

#  Metalbrot

# The Mandelbrot set for Apple Platforms with Metal Acceleration

## DONE

* Basic Apple Platforms targets (macOS, iOS/iPadOS, tvOS)
* Unified Multiplatform Xcode Target
* Metal Shaders to draw and color set
* Basic coloring
* Viewport Sizing
* Pan and Zoom on MacOS, iOS

## Issues
* "Frisky" pan speed at high zoom levels ~ inverse pan speed to zoom level in view model
* "Inverting/flip" drawing during zoom 
* Print doesnt get correct target view

## TODO

* Unit tests for view model
* View model enhancements / optimizations 
* Color options
* Greater control for Pan
* Reset on macOS, iOS
* Print
* Settings, Disable Metal HUD etc

## ROADMAP FEATURES
* Reset Zoom w/ Animation, interpolation
* Shader refactor
