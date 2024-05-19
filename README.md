# Keynote Progress Bar

This AppleScript program adds a customizable progress bar to presentations created with Apple Keynote. The progress bar is configured using commands placed in the presenter notes of your slides. This project utilizes a custom Objective-C framework, `KeynoteProgressBarHelper`, for generating vector graphics (PDF) images of the progress bar.

## Table of Contents

- [[#1. Keynote Progress Bar|1. Keynote Progress Bar]]
- [[#Table of Contents ^toc|Table of Contents]]
	- [[#1. Features|1. Features]]
	- [[#2. Installation and usage|2. Installation and usage]]
	- [[#3. Configuration|3. Configuration]]
		- [[#3.1. Basic syntax of commands|3.1. Basic syntax of commands]]
			- [[#Commands on the initial slide|Commands on the initial slide]]
			- [[#Commands on individual slides|Commands on individual slides]]
		- [[#3.2. Examples|3.2. Examples]]
			- [[#Starting Slide|Starting Slide]]
			- [[#Intermediate Slide|Intermediate Slide]]
			- [[#Ending Slide|Ending Slide]]
			- [[#Slide with Dark Background|Slide with Dark Background]]
	- [[#4. Detailed Options|4. Detailed Options]]
		- [[#4.1. PreserveExistingImages|4.1. PreserveExistingImages]]
		- [[#4.2. SetAllPositionsEqual|4.2. SetAllPositionsEqual]]
		- [[#4.3. RemoveAll|4.3. RemoveAll]]
	- [[#5. Positioning and Resizing|5. Positioning and Resizing]]
	- [[#6. Contributing|6. Contributing]]
	- [[#7. License|7. License]]
	- [[#8. Troubleshooting|8. Troubleshooting]]



## 1. Features

- Customizable progress bar with various styling options
- Support for chapters with different styles
- Easy configuration through presenter notes
- Automatic insertion of progress bar images into Keynote slides

## 2. Installation and usage

1. Clone this repository:
   ```sh
   git clone https://github.com/yourusername/KeynoteProgressBar.git
   ```
2. Open the `KeynoteProgressBarHelper` framework in Xcode and build it.
3. Place the compiled framework in `/Users/your-username/Library/Frameworks`.
4. Open the AppleScript `path/to/the/cloned/repository/AppleScript/Add Progress Bar to Keynote.applescript.applescript` with Apple’s _Script Editor_ and save the script in your favorite script location (e.g., `/Users/your-username/Library/Scripts`) as compiled-script format `.scpt`. 
5. Open your Keynote presentation.
6. Add the configuration commands to the presenter notes of the relevant slides.
7. From the _Script Editor_, run the AppleScript to process the slides and insert the progress bar images. If you have multiple Keynote presentations opened, the foremost document will be considered by the script.
   
## 3. Configuration

To configure the progress bar, add commands to the presenter notes of your Keynote slides. The syntax for the commands is as follows:

### 3.1. Basic syntax of commands

Commands can be provided by including in the _Presenter Notes_ of Keynote a string with the following format:

```plaintext
{progress bar; command; parameter1=value1; parameter2=value2; ...}
```

There are two categories of commands:

1. commands applying to the initial slides. These are typically global configurations.
2. commands applying to the individual slides to customize their particular behavior.


#### Commands on the initial slide

These commands are used in the `{progress bar; start; ...}` configuration on the first slide, where the progress bar is intended to start, to set up the overall behavior and style of the progress bar throughout the presentation:

- `start`: Marks the slide starting from which the progress bar should be displayed.
- `RemoveAll`: (true/false) Removes all progress bars before starting.
- `ChapterSeparation`: (number) Distance between chapter markers in pixels.
- `FontFamily`: (string) Font family for the progress bar text.
- `FontFamilyHighlightedChapter`: (string) Font family for the highlighted chapter text.
- `FontSize`: (number) Font size of the progress bar text.
- `FlipUpsideDown`: (true/false) Flips the progress bar upside down.
- `SetAllPositionsEqual`: (true/false) Sets all progress bar positions to be equal.
- `NumberOfDots`: (integer number) Number of dots in the progress bar.
- `DotSize`: (floating number) Size of the dots in pixels.
- `ContourWidth`: (number) Width of the contour line around the dots.
- `CompletedDotFillColor`: (array) Color of completed dots in RGBA format (e.g., `{91,96,95,100}`).
- `UncompletedDotFillColor`: (array) Color of uncompleted dots in RGBA format.
- `CompletedDotStrokeColor`: (array) Stroke color of completed dots in RGBA format.
- `UncompletedDotStrokeColor`: (array) Stroke color of uncompleted dots in RGBA format.
- `CompletedTextColor`: (array) Color of text for finish and present chapters in RGBA format.
- `UncompletedTextColor`: (array) Color of text for next chapters in RGBA format.
- `BaselineOffset`: (number) Baseline offset for the text.
- `Margins`: (array of numbers) Margins around the progress bar in the format `{top,right,bottom,left}`.
- `PreserveExistingImages`: (true/false) Preserves all existing progress bar images.

#### Commands on individual slides

These commands are applied to individual slides to control their specific behavior and appearance in the context of the progress bar:

- `duration`: (floating-point number) Sets the duration in minutes for the current slide.
- `chapter`: (string) Name of the new chapter in your presentation. You can use double quotation marks if the chapter name contains spaces.
- `skipDrawing`: (no argument) Skips drawing the progress bar for the current slide. This command is convenient to hide the progress bar on slides where it would overlap on some graphical elements.
- `stop`: (no argument) Marks the slides until which the progress bar should be displayed. All slides after the `stop` command will be ignored.

### 3.2. Examples

#### Starting Slide

```plaintext
{progress bar; start; RemoveAll=false; ChapterSeparation=90; FontFamily=Helvetica-Light; FlipUpsideDown=false; FontFamilyHighlightedChapter=Helvetica; SetAllPositionsEqual=true; NumberOfDots=43; DotSize=7; ContourWidth=0.2; FontSize=18; chapter=Introduction; CompletedDotFillColor={91,96,95,100}; UncompletedDotFillColor={91,96,95,30}; CompletedDotStrokeColor={0,0,0,100}; UncompletedDotStrokeColor={0,0,0,100}; BaselineOffset=0; Margins={0,40,0,40}; OverwriteExistingImages=true; skip; duration=1.73}
```

#### Intermediate Slide

```plaintext
{progress bar; duration=1.5}
```

#### Ending Slide

```plaintext
{progress bar; skip; stop}
```

#### Slide with Dark Background

```plaintext
{progress bar; duration=1.5; CompletedDotFillColor={255,255,255,100}; UncompletedDotFillColor={255,255,255,60}; CompletedDotStrokeColor={0,0,0,100}; UncompletedDotStrokeColor={0,0,0,100}; CompletedTextColor={255,255,255,100}; UncompletedTextColor={255,255,255,100};}
```

## 4. Detailed Options

### 4.1. PreserveExistingImages

When this option is false (default), the app uses any previously placed progress bar as a reference and replaces it, maintaining the size, position, and z-order on the slide. This is particularly convenient because sometimes the user may want to put the progress bar as the last element, hidden by other elements in the foreground. By avoiding rewriting the image of the progress bar, we can keep the right z-order.

### 4.2. SetAllPositionsEqual

When this option is true, all progress bar images in all slides have the same size and position as the first progress bar. The first progress bar is the first one appearing. If the first slides use the command `skipDrawing`, then it will be the first progress bar on the first slide not containing `skipDrawing`.

### 4.3. RemoveAll

This is a command in the first slide. When this is true, all images of the progress bar are removed from all slides. This is important when we want to clean the slides from the progress bar. No progress bar is created.

## 5. Positioning and Resizing

The first run of the app, if no previous progress bar existed, places the progress bar at the bottom to fill nearly the entire width. This is seldom ideal. The user is free to change the position by moving the progress bar and resizing it. It is important to uncheck `Constrain proportions` under the panel `Format > Arrange` of Keynote when selecting the progress bar generated in its default position. This allows the user to stretch the progress bar to the desired size. It must be mentioned that in doing so, the aspect ratio may look weird and not properly scaled. The user should not worry. The next execution of the app will use the right size, but also respect the correct aspect ratio for the dots and text.


## 6. Contributing

Contributions are welcome! Please open an issue or submit a pull request with your improvements.

## 7. License

This project is licensed under the MIT License; see the [LICENSE](LICENSE) file for details.

## 8. Troubleshooting

If you encounter any issues, please consider the following steps:
- Ensure you have placed the `KeynoteProgressBarHelper` framework in the correct directory.
- Verify that the syntax in your presenter notes matches the examples provided.
- Check that you have the necessary permissions to run AppleScripts and access Keynote.>)